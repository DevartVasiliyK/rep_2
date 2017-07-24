CREATE TABLE [dbo].[P-2-_binary_uniqueidentifier] (
  [pk_int] [int] NOT NULL,
  [comp_binary_uniqueidentifier] [binary](1) NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO