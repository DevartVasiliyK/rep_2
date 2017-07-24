SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/FixSecurityLoginSp.sp 3     3/31/04 9:03a Blostho $  */
/*
Copyright © MAPICS, Inc. 2003 - All Rights Reserved

Use, duplication, or disclosure by the Government is subject to restrictions
as set forth in subparagraph (c)(1)(ii) of the Rights in Technical Data and
Computer Software clause at DFARS 252.227-7013, and Rights in Data-General at
FAR 52.227.14, as applicable.

Name of Contractor: MAPICS, Inc., 1000 Windward Concourse Parkway Suite 100,
Alpharetta, GA 30005 USA

Unless customer maintains a license to source code, customer shall not:
(i) copy, modify or otherwise update the code contained within this file or
(ii) merge such code with other computer programs.

Provided customer maintains a license to source code, then customer may modify
or otherwise update the code contained within this file or merge such code with
other computer programs subject to the following: (i) customer shall maintain
the source code as the trade secret and confidential information of MAPICS,
Inc. ("MAPICS"), (ii) the source code may only be used for so long as customer
maintains a license to source code pursuant to a separately executed license
agreement, and only for the purpose of developing and supporting customer
specific modifications to the source code, and not for the purpose of
substituting or replacing software support provided by MAPICS; (iii) MAPICS
will have no responsibility to provide software support for any customer
specific modifications developed by or for the customer, including those
developed by MAPICS, unless otherwise agreed to by MAPICS on a time and
materials basis pursuant to a separately executed services agreement;
(iv) MAPICS exclusively retains ownership to all intellectual property rights
associated with the source code, and any derivative works thereof;
(v) upon any expiration or termination of the license agreement, or upon
customer's termination of software support, customer's license to the source
code will immediately terminate and customer shall return the source code to
MAPICS or prepare and send to MAPICS a written affidavit certifying destruction
of the source code within ten (10) days following the expiration or termination
of customer's license right to the source code;
(vi) customer may not copy the source code and may only disclose the source code
to its employees or the employees of a MAPICS affiliate or business partner with
which customer contracts for modifications services, but only for so long as
such employees remain employed by customer or a MAPICS affiliate or business
partner and/or only for so long as there is an agreement in effect between
MAPICS and such affiliate or business partner authorizing them to provide
modification services for the source code ("Authorized Partner" a current list
of Authorized Partners can be found at the following link
http://www.mapics.com/company/SalesOffices/);
(vii) customer shall and shall obligate all employees of customer or an
Authorized Partner that have access to the source code to maintain the source
code as the trade secret and confidential information of MAPICS and to protect
the source code from disclosure to any third parties, including employees of
customer or an Authorized Partner that are not under an obligation to maintain
the confidentiality of the source code; (viii) MAPICS may immediately terminate
a source code license in the event that MAPICS becomes aware of a breach of
these provisions or if, in the commercially reasonable discretion of MAPICS, a
breach is probable; (ix) any breach by customer of its confidentiality
obligations hereunder may cause irreparable damage for which MAPICS may have no
adequate remedy at law, and that MAPICS may exercise all available equitable
remedies, including seeking injunctive relief, without having to post a bond;
and, (x) if Customer becomes aware of a breach or if a breach is probable,
customer will promptly notify MAPICS, and will provide assistance and
cooperation as is necessary to remedy a breach that has already occurred or to
prevent a threatened breach.

MAPICS is a trademark of MAPICS, Inc.

All other product or brand names used in this code may be trademarks,
registered trademarks, or trade names of their respective owners.
*/
CREATE PROCEDURE [dbo].[FixSecurityLoginSp] (
  @SQLServerLogin NVARCHAR(255)
, @Infobar        NVARCHAR(255) OUTPUT
)
AS
DECLARE
 @TempName  sysname
, @IsAliased INT

DECLARE
  @Severity INT
, @DbName   sysname
, @Sid varbinary(85)
, @TempUser NVARCHAR(256)

SET @Infobar = ''

SELECT
  @DbName = DB_NAME()

--  If the local alias exists, but the login with a matching sid doesn't, then
-- the sysusers table was restored by backup, possibly from another server.
-- Create a bogus user matching that alias and then drop the alias and the user.

IF EXISTS (SELECT 1
FROM sysusers
WHERE name = @SQLServerLogin)
AND NOT EXISTS (SELECT 1
  FROM master..syslogins AS sl
  INNER JOIN sysusers AS su ON
    sl.sid = su.sid
  WHERE sl.name = @SQLServerLogin )
BEGIN
    SELECT
      @Sid = sid
    , @IsAliased = isaliased
    FROM sysusers
    WHERE name = @SQLServerLogin

    SET @TempUser = 'temp' + replace (CAST (dbo.GetSiteDate(getdate()) AS NVARCHAR(10)), ' ', 'x')
    IF EXISTS (SELECT 1
      FROM master.dbo.syslogins
      WHERE name = @TempUser)
    BEGIN
        EXEC sp_droplogin @TempUser
    END

    EXEC @Severity = sp_addlogin @loginame = @TempUser, @sid = @Sid
    IF @Severity <> 0
    BEGIN
        SET @Infobar = 'sp_addlogin failed for temp user ' + @TempUser
        RETURN 16
    END
    IF @IsAliased = 1
    BEGIN
        EXEC @Severity = sp_dropalias @TempUser
        IF @Severity <> 0
        BEGIN
            SET @Infobar = 'sp_dropalias failed for Temp User on user ' + @SQLServerLogin
            RETURN 16
        END
    END
    ELSE
    BEGIN
        EXEC @Severity = sp_dropuser @SQLServerLogin
        IF @Severity <> 0
        BEGIN
            SET @Infobar = 'sp_dropalias failed for Temp User on user ' + @SQLServerLogin
            RETURN 16
        END
    END

    EXEC @Severity = sp_droplogin @TempUser
    IF @Severity <> 0
    BEGIN
        SET @Infobar = 'sp_droplogin failed for temp user ' + @TempUser
        RETURN 16
    END
END

-- If the login doesn't exist, add it. Otherwise, reset the password.
IF NOT EXISTS ( SELECT 1
  FROM master..syslogins
  WHERE name = @SQLServerLogin )
BEGIN
    EXECUTE @Severity = sp_addlogin
      @SQLServerLogin
    , NULL
    , @DbName
    IF @Severity <> 0
    BEGIN
        SET @Infobar = 'sp_addlogin failed for user ' + @SQLServerLogin
        RETURN 16
    END
END

-- If there is no user in this database, add it.

IF NOT EXISTS (SELECT 1
FROM sysusers
WHERE name = @SQLServerLogin)
BEGIN
    EXECUTE @Severity = sp_adduser
      @SQLServerLogin
    , @SQLServerLogin
    IF @Severity <> 0
    BEGIN
        SET @Infobar = 'sp_addalias failed for user ' + @SQLServerLogin
        RETURN 16
    END
END
EXECUTE ('GRANT EXECUTE ON GetSQLServerLoginSp TO ' + @SQLServerLogin)

RETURN 0
GO