CREATE TABLE [dbo].[P-2-_uniqueidentifier_varchar(max)] (
  [pk_int] [int] NOT NULL,
  [comp_uniqueidentifier_varchar(max)] [uniqueidentifier] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO