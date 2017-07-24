CREATE TABLE [dbo].[P-2-_uniqueidentifier_varbinary(max)] (
  [pk_int] [int] NOT NULL,
  [comp_uniqueidentifier_varbinary(max)] [uniqueidentifier] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO