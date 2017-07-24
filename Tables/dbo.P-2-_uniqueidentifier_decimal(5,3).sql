CREATE TABLE [dbo].[P-2-_uniqueidentifier_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_uniqueidentifier_decimal(5,3)] [uniqueidentifier] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO