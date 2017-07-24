CREATE TABLE [dbo].[P-2-_text_char] (
  [pk_int] [int] NOT NULL,
  [comp_text_char] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO