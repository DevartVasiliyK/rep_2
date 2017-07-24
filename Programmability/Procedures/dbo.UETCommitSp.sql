SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/UETCommit.sp 5     9/10/04 3:05p Nicthu $  */
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
CREATE PROCEDURE [dbo].[UETCommitSp]
AS
declare
 @UserClassCommittedrowpointer RowPointerType
,@UserClassSysDelete ListYesNoType
,@UserClassClassName ClassNameType
,@UserClassClassLabel LabelType
,@UserClassClassDesc DescriptionType
,@UserClassSysHasFields ListYesNoType
,@UserClassSysHasTables ListYesNoType
,@UserClassSysApply UetSysApplyType
,@UserClassInworkflow FlagNyType
,@UserClassRowpointer RowPointerType
,@ReplacedUserFldCommittedRowpointer RowPointerType
,@UserIndexCommittedrowpointer uniqueidentifier
,@UserIndexIndexName nvarchar(32)
,@UserIndexSysDelete tinyint
,@UserIndexClassName nvarchar(32)
,@UserIndexSysApply nvarchar(6)
,@UserIndexIndexDesc nvarchar(40)
,@UserIndexIndexUnique tinyint
,@UserIndexIndexWord tinyint
,@UserIndexInworkflow tinyint
,@UserIndexRowpointer uniqueidentifier
,@ReplacedTableClassRowpointer RowPointerType
,@TableClassCommittedrowpointer RowPointerType
,@TableClassClassName ClassNameType
,@TableClassSysDelete ListYesNoType
,@TableClassTableName TableNameType
,@TableClassSysApply UetSysApplyType
,@TableClassTableRule QueryExpressionType
,@TableClassExtendAllRecs ListYesNoType
,@TableClassAllowRecordAssoc ListYesNoType
,@TableClassActive ListYesNoType
,@TableClassInworkflow FlagNyType
,@TableClassRowpointer RowPointerType
,@CommittedUserClassRowpointer RowPointerType
,@CommittedUserClassClassName ClassNameType
,@CommittedUserClassClassLabel LabelType
,@CommittedUserClassClassDesc DescriptionType
,@CommittedUserClassSysHasFields ListYesNoType
,@CommittedUserClassSysHasTables ListYesNoType
,@CommittedUserClassSysApply UetSysApplyType
,@CommittedUserClassSysDelete ListYesNoType
,@CommittedUserClassInworkflow FlagNyType
,@ReplacedUserIndexCommittedRowpointer RowPointerType
,@CommittedUserClassFldRowpointer RowPointerType
,@CommittedUserClassFldClassName ClassNameType
,@CommittedUserClassFldFldName FldNameType
,@CommittedUserClassFldSysApply UetSysApplyType
,@CommittedUserClassFldSysDelete ListYesNoType
,@CommittedUserClassFldInworkflow FlagNyType
,@CommittedUserIndexRowpointer RowPointerType
,@CommittedUserIndexClassName ClassNameType
,@CommittedUserIndexIndexName IndexNameType
,@CommittedUserIndexIndexDesc DescriptionType
,@CommittedUserIndexIndexUnique ListYesNoType
,@CommittedUserIndexIndexWord ListYesNoType
,@CommittedUserIndexSysApply UetSysApplyType
,@CommittedUserIndexSysDelete ListYesNoType
,@CommittedUserIndexInworkflow FlagNyType
,@UserIndexFldCommittedrowpointer RowPointerType
,@UserIndexFldClassName ClassNameType
,@UserIndexFldIndexName IndexNameType
,@UserIndexFldIndexSeq UetIndexSeqType
,@UserIndexFldFldName FldNameType
,@UserIndexFldIndexAsc ListYesNoType
,@UserIndexFldInworkflow FlagNyType
,@UserIndexFldRowpointer RowPointerType
,@CommittedTableClassRowpointer RowPointerType
,@CommittedTableClassTableName TableNameType
,@CommittedTableClassClassName ClassNameType
,@CommittedTableClassTableRule QueryExpressionType
,@CommittedTableClassExtendAllRecs ListYesNoType
,@CommittedTableClassSysApply UetSysApplyType
,@CommittedTableClassSysDelete ListYesNoType
,@CommittedTableClassAllowRecordAssoc ListYesNoType
,@CommittedTableClassActive ListYesNoType
,@CommittedTableClassInworkflow FlagNyType
,@UserClassFldClassName ClassNameType
,@UserClassFldFldName FldNameType
,@UserClassFldSysDelete ListYesNoType
,@UserClassFldSysApply UetSysApplyType
,@UserClassFldInworkflow FlagNyType
,@UserClassFldRowpointer RowPointerType
,@UserFldCommittedrowpointer RowPointerType
,@UserFldFldName FldNameType
,@UserFldSysDelete ListYesNoType
,@UserFldRowpointer RowPointerType
,@UserFldSysApply UetSysApplyType
,@UserFldFldDataType UetDataTypeType
,@UserFldFldInitial UetDefaultType
,@UserFldFldDecimals UetScaleType
,@UserFldFldDesc ToolTipType
,@UserFldFldUdt sysname
,@UserFldFldPrec UetPrecisionType
,@UserFldInworkflow FlagNyType
,@CommittedUserFldRowpointer RowPointerType
,@CommittedUserFldSysApply UetSysApplyType
,@CommittedUserFldFldName FldNameType
,@CommittedUserFldFldDataType UetDataTypeType
,@CommittedUserFldFldInitial UetDefaultType
,@CommittedUserFldFldDecimals UetScaleType
,@CommittedUserFldFldDesc ToolTipType
,@CommittedUserFldSysDelete ListYesNoType
,@CommittedUserFldFldUdt sysname
,@CommittedUserFldFldPrec UetPrecisionType
,@CommittedUserFldInworkflow FlagNyType
,@CommittedUserIndexFldRowpointer RowPointerType
,@CommittedUserIndexFldClassName ClassNameType
,@CommittedUserIndexFldIndexName IndexNameType
,@CommittedUserIndexFldIndexSeq UetIndexSeqType
,@CommittedUserIndexFldFldName FldNameType
,@CommittedUserIndexFldIndexAsc ListYesNoType
,@CommittedUserIndexFldInworkflow FlagNyType


/*
declare @deleted_user_fld table (
   fld_name nvarchar(32)
   )
declare @deleted_table_class table (
   class_name nvarchar(32)
   , table_name nvarchar(32)
   )
   */

-- Copy user_index table to @user_index table-variable
-- so we can change it without clobbering original:
declare @user_index table ( class_name nvarchar(32),index_name nvarchar(32),index_desc nvarchar(40),index_unique tinyint,index_word tinyint,sys_apply nvarchar(6),sys_delete tinyint,CommittedRowPointer uniqueidentifier,InWorkflow tinyint
   , RowPointer uniqueidentifier
   )


INSERT INTO @user_index (class_name,index_name,index_desc,index_unique,index_word,sys_apply,sys_delete,CommittedRowPointer,InWorkflow, RowPointer)
SELECT class_name,index_name,index_desc,index_unique,index_word,sys_apply,sys_delete,CommittedRowPointer,InWorkflow, RowPointer FROM user_index


BEGIN TRANSACTION
   /*** Get rid of deleted records that did not come from *_committed
    *** (because they never really existed) ***/
   DELETE FROM user_class
   WHERE sys_delete <> 0
   AND CommittedRowPointer IS NULL

   DELETE FROM user_fld
   WHERE sys_delete <> 0
   AND CommittedRowPointer IS NULL

   DELETE FROM user_class_fld
   WHERE sys_delete <> 0
   AND CommittedRowPointer IS NULL

   DELETE FROM user_index
   WHERE sys_delete <> 0
   AND CommittedRowPointer IS NULL

   DELETE FROM table_class
   WHERE sys_delete <> 0
   AND CommittedRowPointer IS NULL


   /*** user-class ***/

   begin
   declare user_class_crs cursor local static for
   select
    user_class.committedrowpointer
   ,user_class.sys_delete
   ,user_class.class_name
   ,user_class.class_label
   ,user_class.class_desc
   ,user_class.sys_has_fields
   ,user_class.sys_has_tables
   ,user_class.sys_apply
   ,user_class.inworkflow
   ,user_class.rowpointer
   from user_class

   open user_class_crs
   while 1 = 1 begin
      fetch user_class_crs into
       @UserClassCommittedrowpointer
      ,@UserClassSysDelete
      ,@UserClassClassName
      ,@UserClassClassLabel
      ,@UserClassClassDesc
      ,@UserClassSysHasFields
      ,@UserClassSysHasTables
      ,@UserClassSysApply
      ,@UserClassInworkflow
      ,@UserClassRowpointer
      if @@fetch_status <> 0 break


      begin
      select
       @CommittedUserClassRowpointer = committed_user_class.rowpointer
      ,@CommittedUserClassClassName = committed_user_class.class_name
      ,@CommittedUserClassClassLabel = committed_user_class.class_label
      ,@CommittedUserClassClassDesc = committed_user_class.class_desc
      ,@CommittedUserClassSysHasFields = committed_user_class.sys_has_fields
      ,@CommittedUserClassSysHasTables = committed_user_class.sys_has_tables
      ,@CommittedUserClassSysApply = committed_user_class.sys_apply
      ,@CommittedUserClassSysDelete = committed_user_class.sys_delete
      ,@CommittedUserClassInworkflow = committed_user_class.inworkflow
      FROM user_class_committed AS Committed_user_class WITH (UPDLOCK)
          WHERE Committed_user_class.RowPointer = @UserClassCommittedrowpointer

      if @@rowcount <> 1 begin
         set @CommittedUserClassRowpointer = null
      end
      end

      IF (@CommittedUserClassRowpointer is not null) AND @UserClassSysDelete <> 0
      BEGIN
         delete user_class_committed where user_class_committed.rowpointer = @CommittedUserClassRowpointer
      END
      ELSE
      BEGIN
         IF @CommittedUserClassRowpointer is null
         BEGIN
            set @CommittedUserClassRowpointer = newid()
            /*
            BUFFER-COPY user_class
               EXCEPT user_class.CommittedRowPointer
               TO user-class-Committed
               .
             */
            SET @CommittedUserClassClassName = @UserClassClassName
            SET @CommittedUserClassClassLabel = @UserClassClassLabel
            SET @CommittedUserClassClassDesc = @UserClassClassDesc
            SET @CommittedUserClassSysHasFields = @UserClassSysHasFields
            SET @CommittedUserClassSysHasTables = @UserClassSysHasTables
            SET @CommittedUserClassSysApply = @UserClassSysApply
            SET @CommittedUserClassSysDelete = @UserClassSysDelete
            SET @CommittedUserClassInworkflow = @UserClassInworkflow

            insert into user_class_committed (rowpointer, class_name, class_label, class_desc, sys_has_fields, sys_has_tables, sys_apply, sys_delete, inworkflow)
            values(@CommittedUserClassRowpointer, @CommittedUserClassClassName, @CommittedUserClassClassLabel, @CommittedUserClassClassDesc, @CommittedUserClassSysHasFields, @CommittedUserClassSysHasTables, @CommittedUserClassSysApply, @CommittedUserClassSysDelete, @CommittedUserClassInworkflow)

            UPDATE ObjectNotes
               SET RefRowPointer = @CommittedUserClassRowpointer
               FROM NoteHeaders
               INNER JOIN ObjectNotes
                  ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
               WHERE NoteHeaders.ObjectName = 'user_class'
               AND ObjectNotes.RefRowPointer = @UserClassRowpointer

         END
         ELSE
         BEGIN
            SET @CommittedUserClassClassName = @UserClassClassName
            SET @CommittedUserClassClassLabel = @UserClassClassLabel
            SET @CommittedUserClassClassDesc = @UserClassClassDesc
            SET @CommittedUserClassSysHasFields = @UserClassSysHasFields
            SET @CommittedUserClassSysHasTables = @UserClassSysHasTables
            SET @CommittedUserClassSysApply = @UserClassSysApply
            SET @CommittedUserClassSysDelete = @UserClassSysDelete
            SET @CommittedUserClassInworkflow = @UserClassInworkflow

            update user_class_committed
            set
             class_name = @CommittedUserClassClassName
            ,class_label = @CommittedUserClassClassLabel
            ,class_desc = @CommittedUserClassClassDesc
            ,sys_has_fields = @CommittedUserClassSysHasFields
            ,sys_has_tables = @CommittedUserClassSysHasTables
            ,sys_apply = @CommittedUserClassSysApply
            ,sys_delete = @CommittedUserClassSysDelete
            ,inworkflow = @CommittedUserClassInworkflow
            where rowpointer = @CommittedUserClassRowpointer

            UPDATE ObjectNotes
               SET RefRowPointer = @CommittedUserClassRowpointer
               FROM NoteHeaders
               INNER JOIN ObjectNotes
                  ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
               WHERE NoteHeaders.ObjectName = 'user_class'
               AND ObjectNotes.RefRowPointer = @UserClassRowpointer

         END
      END

   end
   close user_class_crs
   deallocate user_class_crs
   end

   /*** user-fld ***/


   begin
   declare user_fld_crs cursor local static for
   select
    user_fld.committedrowpointer
   ,user_fld.fld_name
   ,user_fld.sys_delete
   ,user_fld.rowpointer
   ,user_fld.sys_apply
   ,user_fld.fld_data_type
   ,user_fld.fld_initial
   ,user_fld.fld_decimals
   ,user_fld.fld_desc
   ,user_fld.fld_udt
   ,user_fld.fld_prec
   ,user_fld.inworkflow
   from user_fld

   open user_fld_crs
   while 1 = 1 begin
      fetch user_fld_crs into
       @UserFldCommittedrowpointer
      ,@UserFldFldName
      ,@UserFldSysDelete
      ,@UserFldRowpointer
      ,@UserFldSysApply
      ,@UserFldFldDataType
      ,@UserFldFldInitial
      ,@UserFldFldDecimals
      ,@UserFldFldDesc
      ,@UserFldFldUdt
      ,@UserFldFldPrec
      ,@UserFldInworkflow
      if @@fetch_status <> 0 break

      select
       @CommittedUserFldRowpointer = committed_user_fld.rowpointer
      ,@CommittedUserFldSysApply = committed_user_fld.sys_apply
      ,@CommittedUserFldFldName = committed_user_fld.fld_name
      ,@CommittedUserFldFldDataType = committed_user_fld.fld_data_type
      ,@CommittedUserFldFldInitial = committed_user_fld.fld_initial
      ,@CommittedUserFldFldDecimals = committed_user_fld.fld_decimals
      ,@CommittedUserFldFldDesc = committed_user_fld.fld_desc
      ,@CommittedUserFldSysDelete = committed_user_fld.sys_delete
      ,@CommittedUserFldFldUdt = committed_user_fld.fld_udt
      ,@CommittedUserFldFldPrec = committed_user_fld.fld_prec
      ,@CommittedUserFldInworkflow = committed_user_fld.inworkflow
      FROM user_fld_committed AS Committed_user_fld WITH (UPDLOCK)
          WHERE Committed_user_fld.RowPointer = @UserFldCommittedrowpointer

      if @@rowcount <> 1 begin
         set @CommittedUserFldRowpointer = null
      end

      IF @CommittedUserFldRowpointer is null
      BEGIN
         -- user_fld was NOT previously Committed:
         set @CommittedUserFldRowpointer = newid()

         -- UI did NOT request to Delete this user_fld:
         IF EXISTS(SELECT 1 FROM user_class_fld_impacted
            INNER JOIN table_class_impacted
            ON table_class_impacted.class_name = user_class_fld_impacted.class_name
            WHERE user_class_fld_impacted.fld_name = @UserFldFldName)
         BEGIN
            /*+
               Only change previous status of sys-apply if Impact-Schema was done,
               else leave the previous value of sys-apply and when the user Impact
               the schema the contents of the physical storage will be the freshed
               information stored in the UET-Dictionary.
               This is true if the field is used in any Table/Class relationship.
            -*/
            SET @UserFldSysApply = 'Create'
         END

         /* If user create the same field before impact schema
            we delete the stored field so impact replace
            the original impacted with freshest one */
         DELETE user_fld_committed
         WHERE user_fld_committed.fld_name = @UserFldFldName
         AND user_fld_committed.RowPointer <> @UserFldCommittedrowpointer


         SET @CommittedUserFldFldName = @UserFldFldName
         SET @CommittedUserFldFldDataType = @UserFldFldDataType
         SET @CommittedUserFldFldInitial = @UserFldFldInitial
         SET @CommittedUserFldFldDecimals = @UserFldFldDecimals
         SET @CommittedUserFldFldDesc = @UserFldFldDesc
         SET @CommittedUserFldSysApply = @UserFldSysApply
         SET @CommittedUserFldSysDelete = @UserFldSysDelete
         SET @CommittedUserFldFldUdt = @UserFldFldUdt
         SET @CommittedUserFldFldPrec = @UserFldFldPrec
         SET @CommittedUserFldInworkflow = @UserFldInworkflow

         insert into user_fld_committed (rowpointer, fld_name, fld_data_type, fld_initial, fld_decimals, fld_desc, sys_apply, sys_delete, fld_udt, fld_prec, inworkflow)
         values(@CommittedUserFldRowpointer, @CommittedUserFldFldName, @CommittedUserFldFldDataType, @CommittedUserFldFldInitial, @CommittedUserFldFldDecimals, @CommittedUserFldFldDesc, @CommittedUserFldSysApply, @CommittedUserFldSysDelete, @CommittedUserFldFldUdt, @CommittedUserFldFldPrec, @CommittedUserFldInworkflow)

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedUserFldRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'user_fld'
            AND ObjectNotes.RefRowPointer = @UserFldRowpointer

      END
      ELSE
      BEGIN
         -- user_fld WAS previously Committed:
         IF @UserFldSysDelete <> 0
         BEGIN
            -- UI requested to Delete this user_fld:
            IF EXISTS(SELECT 1 FROM user_class_fld_impacted
               INNER JOIN table_class_impacted
                  ON table_class_impacted.class_name = user_class_fld_impacted.class_name
               WHERE user_class_fld_impacted.fld_name = @UserFldFldName)
               /**
               EXISTS(SELECT 1 FROM syscolumns AS col
               INNER JOIN sysobjects AS tab
               ON tab.type = 'U' AND tab.id = col.id
               WHERE col.name = @UserFldFldName)
                **/

            BEGIN
               -- user_fld WAS previously Impacted for a user_class_fld
               SET @UserFldSysApply = 'Delete'
            END
            ELSE
            BEGIN
               -- user_fld was NOT previously Impacted for a user_class_fld
               delete user_fld_committed where user_fld_committed.rowpointer = @CommittedUserFldRowpointer

               CONTINUE
            END
         END
         ELSE
         BEGIN
            -- UI did NOT request to Delete this user_fld:
            IF EXISTS(SELECT 1 FROM user_class_fld_impacted
               INNER JOIN table_class_impacted
               ON table_class_impacted.class_name = user_class_fld_impacted.class_name
               WHERE user_class_fld_impacted.fld_name = @UserFldFldName)
            BEGIN
               /*+
                  Only change previous status of sys-apply if Impact-Schema was done,
                  else leave the previous value of sys-apply and when the user Impact
                  the schema the contents of the physical storage will be the freshed
                  information stored in the UET-Dictionary.
                  This is true if the field is used in any Table/Class relationship.
               -*/
               IF @CommittedUserFldSysApply IS NULL
               BEGIN
                  SET @UserFldSysApply = CASE WHEN @UserFldFldName <> @CommittedUserFldFldName OR @UserFldFldDataType <> @CommittedUserFldFldDataType OR ISNULL(@UserFldFldInitial,'') <> ISNULL(@CommittedUserFldFldInitial,'') OR @UserFldFldDecimals <> @CommittedUserFldFldDecimals OR ISNULL(@UserFldFldDesc,'') <> ISNULL(@CommittedUserFldFldDesc,'') OR ISNULL(@UserFldSysApply,'') <> ISNULL(@CommittedUserFldSysApply,'') OR @UserFldSysDelete <> @CommittedUserFldSysDelete OR @UserFldFldUdt <> @CommittedUserFldFldUdt OR @UserFldFldPrec <> @CommittedUserFldFldPrec OR @UserFldInworkflow <> @CommittedUserFldInworkflow
                     THEN 'Update'
                     ELSE NULL
                     END
               END
            END
         END

         /* If user create the same field before impact schema
            we delete the stored field so impact replace
            the original impacted with freshest one */
         DELETE user_fld_committed
         WHERE user_fld_committed.fld_name = @UserFldFldName
         AND user_fld_committed.RowPointer <> @UserFldCommittedrowpointer

         SET @CommittedUserFldFldName = @UserFldFldName
         SET @CommittedUserFldFldDataType = @UserFldFldDataType
         SET @CommittedUserFldFldInitial = @UserFldFldInitial
         SET @CommittedUserFldFldDecimals = @UserFldFldDecimals
         SET @CommittedUserFldFldDesc = @UserFldFldDesc
         SET @CommittedUserFldSysApply = @UserFldSysApply
         SET @CommittedUserFldSysDelete = @UserFldSysDelete
         SET @CommittedUserFldFldUdt = @UserFldFldUdt
         SET @CommittedUserFldFldPrec = @UserFldFldPrec
         SET @CommittedUserFldInworkflow = @UserFldInworkflow

         update user_fld_committed
         set
          fld_name = @CommittedUserFldFldName
         ,fld_data_type = @CommittedUserFldFldDataType
         ,fld_initial = @CommittedUserFldFldInitial
         ,fld_decimals = @CommittedUserFldFldDecimals
         ,fld_desc = @CommittedUserFldFldDesc
         ,sys_apply = @CommittedUserFldSysApply
         ,sys_delete = @CommittedUserFldSysDelete
         ,fld_udt = @CommittedUserFldFldUdt
         ,fld_prec = @CommittedUserFldFldPrec
         ,inworkflow = @CommittedUserFldInworkflow
         where rowpointer = @CommittedUserFldRowpointer

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedUserFldRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'user_fld'
            AND ObjectNotes.RefRowPointer = @UserFldRowpointer

      END


   end
   close user_fld_crs
   deallocate user_fld_crs
   end

   /*** table-class ***/

   begin
   declare table_class_crs cursor local static for
   select
    table_class.committedrowpointer
   ,table_class.class_name
   ,table_class.sys_delete
   ,table_class.table_name
   ,table_class.sys_apply
   ,table_class.table_rule
   ,table_class.extend_all_recs
   ,table_class.allow_record_assoc
   ,table_class.active
   ,table_class.inworkflow
   ,table_class.rowpointer
   from table_class

   open table_class_crs
   while 1 = 1 begin
      fetch table_class_crs into
       @TableClassCommittedrowpointer
      ,@TableClassClassName
      ,@TableClassSysDelete
      ,@TableClassTableName
      ,@TableClassSysApply
      ,@TableClassTableRule
      ,@TableClassExtendAllRecs
      ,@TableClassAllowRecordAssoc
      ,@TableClassActive
      ,@TableClassInworkflow
      ,@TableClassRowpointer
      if @@fetch_status <> 0 break

      select
       @CommittedTableClassRowpointer = committed_table_class.rowpointer
      ,@CommittedTableClassTableName = committed_table_class.table_name
      ,@CommittedTableClassClassName = committed_table_class.class_name
      ,@CommittedTableClassTableRule = committed_table_class.table_rule
      ,@CommittedTableClassExtendAllRecs = committed_table_class.extend_all_recs
      ,@CommittedTableClassSysApply = committed_table_class.sys_apply
      ,@CommittedTableClassSysDelete = committed_table_class.sys_delete
      ,@CommittedTableClassAllowRecordAssoc = committed_table_class.allow_record_assoc
      ,@CommittedTableClassActive = committed_table_class.active
      ,@CommittedTableClassInworkflow = committed_table_class.inworkflow
      from table_class_committed as Committed_table_class WITH (UPDLOCK)
          WHERE Committed_table_class.RowPointer = @TableClassCommittedrowpointer
      if @@rowcount <> 1 begin
         set @CommittedTableClassRowpointer = null
      end

      DECLARE @NewTableClass bit
      SET @NewTableClass = 0


      IF @CommittedTableClassRowpointer is null
      BEGIN
         SET @NewTableClass = 1

         set @CommittedTableClassRowpointer = newid()

         /*+
            Update user_fld_committed.sys-apply.
         -*/
         SET @TableClassSysApply = 'Create'

         UPDATE user_fld_committed
            SET sys_apply = 'Create'
         FROM user_class_fld_committed
         INNER JOIN user_fld_committed
            ON user_fld_committed.fld_name = user_class_fld_committed.fld_name
         WHERE user_class_fld_committed.class_name = @TableClassClassName
         AND user_fld_committed.sys_apply IS NULL

         UPDATE @user_index
            SET sys_apply = 'Create'
         FROM @user_index AS user_index
         WHERE user_index.class_name = @TableClassClassName

         /* If user create the same table-class relationship before
            impact schema we delete the stored relationship so impact replace
            the original impacted with freshest one */

         DELETE FROM table_class_committed
            WHERE table_class_committed.table_name = @TableClassTableName
            AND table_class_committed.class_name = @TableClassClassName
            AND table_class_committed.RowPointer <> @TableClassCommittedrowpointer


         SET @CommittedTableClassTableName = @TableClassTableName
         SET @CommittedTableClassClassName = @TableClassClassName
         SET @CommittedTableClassTableRule = @TableClassTableRule
         SET @CommittedTableClassExtendAllRecs = @TableClassExtendAllRecs
         SET @CommittedTableClassSysApply = @TableClassSysApply
         SET @CommittedTableClassSysDelete = @TableClassSysDelete
         SET @CommittedTableClassAllowRecordAssoc = @TableClassAllowRecordAssoc
         SET @CommittedTableClassActive = @TableClassActive
         SET @CommittedTableClassInworkflow = @TableClassInworkflow

         insert into table_class_committed (rowpointer, table_name, class_name, table_rule, extend_all_recs, sys_apply, sys_delete, allow_record_assoc, active, inworkflow)
         values(@CommittedTableClassRowpointer, @CommittedTableClassTableName, @CommittedTableClassClassName, @CommittedTableClassTableRule, @CommittedTableClassExtendAllRecs, @CommittedTableClassSysApply, @CommittedTableClassSysDelete, @CommittedTableClassAllowRecordAssoc, @CommittedTableClassActive, @CommittedTableClassInworkflow)

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedTableClassRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'table_class'
            AND ObjectNotes.RefRowPointer = @TableClassRowpointer

      END
      ELSE
      BEGIN
         IF @TableClassSysDelete <> 0
         BEGIN
            /*+
               1) If the table-class was impacted:
                  We do not delete table-class until Impact-Schema is done.
                  Also we rename the table-class.class-name prefixing with "_" to allow
                  the user create the same table-class relationship again.

               2) If the table-class was not impacted we will delete the table-class
                  from UET-Schema
            -*/

             /* To know if the table-class was impacted we need to
                trust in the fields! */
            IF EXISTS(SELECT 1 FROM user_class_fld_committed
               WHERE user_class_fld_committed.class_name = @TableClassClassName
               AND EXISTS(SELECT 1 FROM user_class_fld_impacted
               INNER JOIN table_class_impacted
                  ON table_class_impacted.class_name = user_class_fld_impacted.class_name
               WHERE user_class_fld_impacted.fld_name = user_class_fld_committed.fld_name)
               /**
               EXISTS(SELECT 1 FROM syscolumns AS col
               INNER JOIN sysobjects AS tab
               ON tab.type = 'U' AND tab.id = col.id
               WHERE col.name = user_class_fld_committed.fld_name)
                **/
               )
            BEGIN
               SET @TableClassSysApply = 'Delete'
            END
            ELSE
            BEGIN
               delete table_class_committed where table_class_committed.rowpointer = @CommittedTableClassRowpointer

               CONTINUE
            END
         END

         /* If user create the same table-class relationship before
            impact schema we delete the stored relationship so impact replace
            the original impacted with freshest one */

         DELETE FROM table_class_committed
            WHERE table_class_committed.table_name = @TableClassTableName
            AND table_class_committed.class_name = @TableClassClassName
            AND table_class_committed.RowPointer <> @TableClassCommittedrowpointer


         SET @CommittedTableClassTableName = @TableClassTableName
         SET @CommittedTableClassClassName = @TableClassClassName
         SET @CommittedTableClassTableRule = @TableClassTableRule
         SET @CommittedTableClassExtendAllRecs = @TableClassExtendAllRecs
         SET @CommittedTableClassSysApply = @TableClassSysApply
         SET @CommittedTableClassSysDelete = @TableClassSysDelete
         SET @CommittedTableClassAllowRecordAssoc = @TableClassAllowRecordAssoc
         SET @CommittedTableClassActive = @TableClassActive
         SET @CommittedTableClassInworkflow = @TableClassInworkflow

         update table_class_committed
         set
          table_name = @CommittedTableClassTableName
         ,class_name = @CommittedTableClassClassName
         ,table_rule = @CommittedTableClassTableRule
         ,extend_all_recs = @CommittedTableClassExtendAllRecs
         ,sys_apply = @CommittedTableClassSysApply
         ,sys_delete = @CommittedTableClassSysDelete
         ,allow_record_assoc = @CommittedTableClassAllowRecordAssoc
         ,active = @CommittedTableClassActive
         ,inworkflow = @CommittedTableClassInworkflow
         where rowpointer = @CommittedTableClassRowpointer

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedTableClassRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'table_class'
            AND ObjectNotes.RefRowPointer = @TableClassRowpointer

      END


   end
   close table_class_crs
   deallocate table_class_crs
   end

   /*** user-class-fld ***/

   begin
   declare user_class_fld_crs cursor local static for
   select
    user_class_fld.class_name
   ,user_class_fld.fld_name
   ,user_class_fld.sys_delete
   ,user_class_fld.sys_apply
   ,user_class_fld.inworkflow
   ,user_class_fld.rowpointer
   from user_class_fld

   open user_class_fld_crs
   while 1 = 1 begin
      fetch user_class_fld_crs into
       @UserClassFldClassName
      ,@UserClassFldFldName
      ,@UserClassFldSysDelete
      ,@UserClassFldSysApply
      ,@UserClassFldInworkflow
      ,@UserClassFldRowpointer
      if @@fetch_status <> 0 break

      select
       @CommittedUserClassFldRowpointer = committed_user_class_fld.rowpointer
      ,@CommittedUserClassFldClassName = committed_user_class_fld.class_name
      ,@CommittedUserClassFldFldName = committed_user_class_fld.fld_name
      ,@CommittedUserClassFldSysApply = committed_user_class_fld.sys_apply
      ,@CommittedUserClassFldSysDelete = committed_user_class_fld.sys_delete
      ,@CommittedUserClassFldInworkflow = committed_user_class_fld.inworkflow
      from user_class_fld_committed AS Committed_user_class_fld WITH (UPDLOCK)
          WHERE Committed_user_class_fld.class_name = @UserClassFldClassName
         AND Committed_user_class_fld.fld_name = @UserClassFldFldName

      if @@rowcount <> 1 begin
         set @CommittedUserClassFldRowpointer = null
      end

      IF @CommittedUserClassFldRowpointer is null
      BEGIN
         set @CommittedUserClassFldRowpointer = newid()

         /*+
            Update user_fld_committed.sys-apply.
         -*/
         IF EXISTS(SELECT 1 FROM user_class_fld
            INNER JOIN table_class
            ON table_class.class_name = user_class_fld.class_name
            WHERE user_class_fld.fld_name = @UserClassFldFldName)
         BEGIN
            -- User Field has been Impacted in any Table:
            UPDATE user_fld_committed
               SET sys_apply = 'Create'
            WHERE user_fld_committed.fld_name = @UserClassFldFldName
            AND user_fld_committed.sys_apply IS NULL
         END

         SET @UserClassFldSysApply = NULL

         SET @CommittedUserClassFldClassName = @UserClassFldClassName
         SET @CommittedUserClassFldFldName = @UserClassFldFldName
         SET @CommittedUserClassFldSysApply = @UserClassFldSysApply
         SET @CommittedUserClassFldSysDelete = @UserClassFldSysDelete
         SET @CommittedUserClassFldInworkflow = @UserClassFldInworkflow

         insert into user_class_fld_committed (rowpointer, class_name, fld_name, sys_apply, sys_delete, inworkflow)
         values(@CommittedUserClassFldRowpointer, @CommittedUserClassFldClassName, @CommittedUserClassFldFldName, @CommittedUserClassFldSysApply, @CommittedUserClassFldSysDelete, @CommittedUserClassFldInworkflow)

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedUserClassFldRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'user_class_fld'
            AND ObjectNotes.RefRowPointer = @UserClassFldRowpointer

      END
      ELSE
      BEGIN
         -- user_class_fld WAS previously Committed:
         IF @UserClassFldSysDelete <> 0
         BEGIN
            -- UI requested to Delete this user_class_fld:
            IF EXISTS(SELECT 1 FROM user_class_fld_impacted
               WHERE user_class_fld_impacted.class_name = @UserClassFldClassName
               AND user_class_fld_impacted.fld_name = @UserClassFldFldName)
            BEGIN
               -- user_class_fld WAS previously Impacted:
               SET @UserClassFldSysApply = 'Delete'
            END
            ELSE
            BEGIN
               -- user_class_fld was NOT previously Impacted:
               delete user_class_fld_committed where user_class_fld_committed.rowpointer = @CommittedUserClassFldRowpointer

               CONTINUE
            END
         END
         ELSE
         BEGIN
            -- UI did NOT request to Delete this user_class_fld:
            /*+
               Update user_fld_committed.sys-apply.
            -*/
            SET @UserClassFldSysApply = CASE WHEN (@UserClassFldClassName <> @CommittedUserClassFldClassName OR @UserClassFldFldName <> @CommittedUserClassFldFldName OR @UserClassFldSysApply <> @CommittedUserClassFldSysApply OR @UserClassFldSysDelete <> @CommittedUserClassFldSysDelete OR @UserClassFldInworkflow <> @CommittedUserClassFldInworkflow)
               THEN 'Update'
               ELSE NULL
               END

         END

         SET @CommittedUserClassFldClassName = @UserClassFldClassName
         SET @CommittedUserClassFldFldName = @UserClassFldFldName
         SET @CommittedUserClassFldSysApply = @UserClassFldSysApply
         SET @CommittedUserClassFldSysDelete = @UserClassFldSysDelete
         SET @CommittedUserClassFldInworkflow = @UserClassFldInworkflow

         update user_class_fld_committed
         set
          class_name = @CommittedUserClassFldClassName
         ,fld_name = @CommittedUserClassFldFldName
         ,sys_apply = @CommittedUserClassFldSysApply
         ,sys_delete = @CommittedUserClassFldSysDelete
         ,inworkflow = @CommittedUserClassFldInworkflow
         where rowpointer = @CommittedUserClassFldRowpointer

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedUserClassFldRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'user_class_fld'
            AND ObjectNotes.RefRowPointer = @UserClassFldRowpointer

      END


   end
   close user_class_fld_crs
   deallocate user_class_fld_crs
   end

   /*** user-index ***/
   -- Use the local table which might have been modified above

   begin
   declare user_index_crs cursor local static for
   select
    user_index.committedrowpointer
   ,user_index.index_name
   ,user_index.sys_delete
   ,user_index.class_name
   ,user_index.sys_apply
   ,user_index.index_desc
   ,user_index.index_unique
   ,user_index.index_word
   ,user_index.inworkflow
   ,user_index.rowpointer
   from @user_index AS user_index

   open user_index_crs
   while 1 = 1 begin
      fetch user_index_crs into
       @UserIndexCommittedrowpointer
      ,@UserIndexIndexName
      ,@UserIndexSysDelete
      ,@UserIndexClassName
      ,@UserIndexSysApply
      ,@UserIndexIndexDesc
      ,@UserIndexIndexUnique
      ,@UserIndexIndexWord
      ,@UserIndexInworkflow
      ,@UserIndexRowpointer
      if @@fetch_status <> 0 break

      select
       @CommittedUserIndexRowpointer = committed_user_index.rowpointer
      ,@CommittedUserIndexClassName = committed_user_index.class_name
      ,@CommittedUserIndexIndexName = committed_user_index.index_name
      ,@CommittedUserIndexIndexDesc = committed_user_index.index_desc
      ,@CommittedUserIndexIndexUnique = committed_user_index.index_unique
      ,@CommittedUserIndexIndexWord = committed_user_index.index_word
      ,@CommittedUserIndexSysApply = committed_user_index.sys_apply
      ,@CommittedUserIndexSysDelete = committed_user_index.sys_delete
      ,@CommittedUserIndexInworkflow = committed_user_index.inworkflow
      from user_index_committed AS Committed_user_index WITH (UPDLOCK)
          WHERE Committed_user_index.RowPointer = @UserIndexCommittedrowpointer
      if @@rowcount <> 1 begin
         set @CommittedUserIndexRowpointer = null
      end

      IF @CommittedUserIndexRowpointer is null
      BEGIN
         set @CommittedUserIndexRowpointer = newid()

         SET @UserIndexSysApply = 'Create'

         SET @CommittedUserIndexClassName = @UserIndexClassName
         SET @CommittedUserIndexIndexName = @UserIndexIndexName
         SET @CommittedUserIndexIndexDesc = @UserIndexIndexDesc
         SET @CommittedUserIndexIndexUnique = @UserIndexIndexUnique
         SET @CommittedUserIndexIndexWord = @UserIndexIndexWord
         SET @CommittedUserIndexSysApply = @UserIndexSysApply
         SET @CommittedUserIndexSysDelete = @UserIndexSysDelete
         SET @CommittedUserIndexInworkflow = @UserIndexInworkflow

         insert into user_index_committed (rowpointer, class_name, index_name, index_desc, index_unique, index_word, sys_apply, sys_delete, inworkflow)
         values(@CommittedUserIndexRowpointer, @CommittedUserIndexClassName, @CommittedUserIndexIndexName, @CommittedUserIndexIndexDesc, @CommittedUserIndexIndexUnique, @CommittedUserIndexIndexWord, @CommittedUserIndexSysApply, @CommittedUserIndexSysDelete, @CommittedUserIndexInworkflow)

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedUserIndexRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'user_index'
            AND ObjectNotes.RefRowPointer = @UserIndexRowpointer

      END
      ELSE
      BEGIN
         IF @UserIndexSysDelete <> 0
         BEGIN
            /* we delete the index-components (user_index_fld_committed) anyway */
            DELETE user_index_fld_committed
            WHERE user_index_fld_committed.class_name = @UserIndexClassName
            AND user_index_fld_committed.index_name = @UserIndexIndexName

            IF EXISTS(SELECT 1 FROM user_index_impacted
               INNER JOIN table_class_impacted
                  ON table_class_impacted.class_name = user_index_impacted.class_name
               WHERE user_index_impacted.index_name = @UserIndexIndexName)
               /**
               EXISTS(SELECT 1 FROM sysindexes AS idx
               INNER JOIN sysobjects AS tab
               ON tab.type = 'U' AND tab.id = idx.id
               WHERE idx.name = @UserIndexIndexName)
                **/
            BEGIN
               SET @UserIndexSysApply = 'Delete'
            END
            ELSE
            BEGIN
               delete user_index_committed where user_index_committed.rowpointer = @CommittedUserIndexRowpointer

               CONTINUE
            END
         END

         /* If user create the same index before impact schema
            we delete the stored index so impact schema replace
            the original impacted with the freshest one
          */
         DELETE FROM user_index_committed
         WHERE user_index_committed.class_name = @UserIndexClassName
         AND user_index_committed.index_name = @UserIndexIndexName
            AND user_index_committed.RowPointer <> @UserIndexCommittedrowpointer

         -- IF @@ROWCOUNT = 1  -- Emulates commit.p, but does not work here
         DELETE FROM user_index_fld_committed
         WHERE user_index_fld_committed.class_name = @UserIndexClassName
         AND user_index_fld_committed.index_name = @UserIndexIndexName

         SET @CommittedUserIndexClassName = @UserIndexClassName
         SET @CommittedUserIndexIndexName = @UserIndexIndexName
         SET @CommittedUserIndexIndexDesc = @UserIndexIndexDesc
         SET @CommittedUserIndexIndexUnique = @UserIndexIndexUnique
         SET @CommittedUserIndexIndexWord = @UserIndexIndexWord
         SET @CommittedUserIndexSysApply = @UserIndexSysApply
         SET @CommittedUserIndexSysDelete = @UserIndexSysDelete
         SET @CommittedUserIndexInworkflow = @UserIndexInworkflow

         update user_index_committed
         set
          class_name = @CommittedUserIndexClassName
         ,index_name = @CommittedUserIndexIndexName
         ,index_desc = @CommittedUserIndexIndexDesc
         ,index_unique = @CommittedUserIndexIndexUnique
         ,index_word = @CommittedUserIndexIndexWord
         ,sys_apply = @CommittedUserIndexSysApply
         ,sys_delete = @CommittedUserIndexSysDelete
         ,inworkflow = @CommittedUserIndexInworkflow
         where rowpointer = @CommittedUserIndexRowpointer

         UPDATE ObjectNotes
            SET RefRowPointer = @CommittedUserIndexRowpointer
            FROM NoteHeaders
            INNER JOIN ObjectNotes
               ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
            WHERE NoteHeaders.ObjectName = 'user_index'
            AND ObjectNotes.RefRowPointer = @UserIndexRowpointer

      END

      IF @UserIndexSysDelete = 0
      BEGIN
         /* Copy all index components (user_index_fld_committed) */
         begin
         declare user_index_fld_crs cursor local static for
         select
          user_index_fld.committedrowpointer
         ,user_index_fld.class_name
         ,user_index_fld.index_name
         ,user_index_fld.index_seq
         ,user_index_fld.fld_name
         ,user_index_fld.index_asc
         ,user_index_fld.inworkflow
         ,user_index_fld.rowpointer
         from user_index_fld
         WHERE user_index_fld.class_name = @UserIndexClassName
         AND user_index_fld.index_name = @UserIndexIndexName

         open user_index_fld_crs
         while 1 = 1 begin
            fetch user_index_fld_crs into
             @UserIndexFldCommittedrowpointer
            ,@UserIndexFldClassName
            ,@UserIndexFldIndexName
            ,@UserIndexFldIndexSeq
            ,@UserIndexFldFldName
            ,@UserIndexFldIndexAsc
            ,@UserIndexFldInworkflow
            ,@UserIndexFldRowpointer
            if @@fetch_status <> 0 break

            select
             @CommittedUserIndexFldRowpointer = committed_user_index_fld.rowpointer
            ,@CommittedUserIndexFldClassName = committed_user_index_fld.class_name
            ,@CommittedUserIndexFldIndexName = committed_user_index_fld.index_name
            ,@CommittedUserIndexFldIndexSeq = committed_user_index_fld.index_seq
            ,@CommittedUserIndexFldFldName = committed_user_index_fld.fld_name
            ,@CommittedUserIndexFldIndexAsc = committed_user_index_fld.index_asc
            ,@CommittedUserIndexFldInworkflow = committed_user_index_fld.inworkflow
            from user_index_fld_committed AS Committed_user_index_fld WITH (UPDLOCK)
                WHERE Committed_user_index_fld.RowPointer = @UserIndexFldCommittedrowpointer

            if @@rowcount <> 1 begin
               set @CommittedUserIndexFldRowpointer = null
            end

            IF @CommittedUserIndexFldRowpointer is null
            BEGIN

               set @CommittedUserIndexFldRowpointer = newid()

               SET @CommittedUserIndexFldClassName = @UserIndexFldClassName
               SET @CommittedUserIndexFldIndexName = @UserIndexFldIndexName
               SET @CommittedUserIndexFldIndexSeq = @UserIndexFldIndexSeq
               SET @CommittedUserIndexFldFldName = @UserIndexFldFldName
               SET @CommittedUserIndexFldIndexAsc = @UserIndexFldIndexAsc
               SET @CommittedUserIndexFldInworkflow = @UserIndexFldInworkflow

               insert into user_index_fld_committed (rowpointer, class_name, index_name, index_seq, fld_name, index_asc, inworkflow)
               values(@CommittedUserIndexFldRowpointer, @CommittedUserIndexFldClassName, @CommittedUserIndexFldIndexName, @CommittedUserIndexFldIndexSeq, @CommittedUserIndexFldFldName, @CommittedUserIndexFldIndexAsc, @CommittedUserIndexFldInworkflow)

               UPDATE ObjectNotes
                  SET RefRowPointer = @CommittedUserIndexFldRowpointer
                  FROM NoteHeaders
                  INNER JOIN ObjectNotes
                     ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
                  WHERE NoteHeaders.ObjectName = 'user_index_fld'
                  AND ObjectNotes.RefRowPointer = @UserIndexFldRowpointer

            END
            ELSE
            BEGIN
               SET @CommittedUserIndexFldClassName = @UserIndexFldClassName
               SET @CommittedUserIndexFldIndexName = @UserIndexFldIndexName
               SET @CommittedUserIndexFldIndexSeq = @UserIndexFldIndexSeq
               SET @CommittedUserIndexFldFldName = @UserIndexFldFldName
               SET @CommittedUserIndexFldIndexAsc = @UserIndexFldIndexAsc
               SET @CommittedUserIndexFldInworkflow = @UserIndexFldInworkflow

               update user_index_fld_committed
               set
                class_name = @CommittedUserIndexFldClassName
               ,index_name = @CommittedUserIndexFldIndexName
               ,index_seq = @CommittedUserIndexFldIndexSeq
               ,fld_name = @CommittedUserIndexFldFldName
               ,index_asc = @CommittedUserIndexFldIndexAsc
               ,inworkflow = @CommittedUserIndexFldInworkflow
               where rowpointer = @CommittedUserIndexFldRowpointer

               UPDATE ObjectNotes
                  SET RefRowPointer = @CommittedUserIndexFldRowpointer
                  FROM NoteHeaders
                  INNER JOIN ObjectNotes
                     ON ObjectNotes.NoteHeaderToken = NoteHeaders.NoteHeaderToken
                  WHERE NoteHeaders.ObjectName = 'user_index_fld'
                  AND ObjectNotes.RefRowPointer = @UserIndexFldRowpointer

            END

         end
         close user_index_fld_crs
         deallocate user_index_fld_crs
         end
      END

   end
   close user_index_crs
   deallocate user_index_crs
   end  /* user_index */



EXEC UETRefreshSp

COMMIT TRANSACTION
GO