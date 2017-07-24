CREATE TABLE [dbo].[P-2-_image_image] (
  [pk_int] [int] NOT NULL,
  [comp_image_image] [image] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO