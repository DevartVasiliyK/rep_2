CREATE TABLE [dbo].[P-2-_text_varchar(30)] (
  [pk_int] [int] NOT NULL,
  [comp_text_varchar(30)] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO