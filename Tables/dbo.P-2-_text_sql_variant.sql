CREATE TABLE [dbo].[P-2-_text_sql_variant] (
  [pk_int] [int] NOT NULL,
  [comp_text_sql_variant] [text] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO