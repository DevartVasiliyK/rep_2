CREATE TABLE [dbo].[P-2-_binary_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_binary_decimal(5,3)] [binary](1) NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO