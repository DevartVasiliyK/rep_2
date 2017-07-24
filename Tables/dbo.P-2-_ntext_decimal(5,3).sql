CREATE TABLE [dbo].[P-2-_ntext_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_ntext_decimal(5,3)] [ntext] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO