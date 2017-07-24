CREATE TABLE [dbo].[P-2-_binary_char(100)] (
  [pk_int] [int] NOT NULL,
  [comp_binary_char(100)] [binary](1) NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO