CREATE TABLE [dbo].[P-2-_text_float] (
  [pk_int] [int] NOT NULL,
  [comp_text_float] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO