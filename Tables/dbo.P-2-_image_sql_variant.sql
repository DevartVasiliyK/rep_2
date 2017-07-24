CREATE TABLE [dbo].[P-2-_image_sql_variant] (
  [pk_int] [int] NOT NULL,
  [comp_image_sql_variant] [image] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO