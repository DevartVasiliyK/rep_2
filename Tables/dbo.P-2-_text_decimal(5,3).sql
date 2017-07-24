CREATE TABLE [dbo].[P-2-_text_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_text_decimal(5,3)] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO