CREATE TABLE [dbo].[P-2-_text_image] (
  [pk_int] [int] NOT NULL,
  [comp_text_image] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO