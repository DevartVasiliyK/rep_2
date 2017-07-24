CREATE TABLE [dbo].[P-2-_uniqueidentifier_char(100)] (
  [pk_int] [int] NOT NULL,
  [comp_uniqueidentifier_char(100)] [uniqueidentifier] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO