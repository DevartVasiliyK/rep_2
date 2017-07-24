CREATE TABLE [dbo].[P-2-_text_ntext] (
  [pk_int] [int] NOT NULL,
  [comp_text_ntext] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO