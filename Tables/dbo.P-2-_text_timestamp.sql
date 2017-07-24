CREATE TABLE [dbo].[P-2-_text_timestamp] (
  [pk_int] [int] NOT NULL,
  [comp_text_timestamp] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO