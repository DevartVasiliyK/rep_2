CREATE TABLE [dbo].[P-2-_image_ntext] (
  [pk_int] [int] NOT NULL,
  [comp_image_ntext] [image] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO