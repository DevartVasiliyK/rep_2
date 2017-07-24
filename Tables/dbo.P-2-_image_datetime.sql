CREATE TABLE [dbo].[P-2-_image_datetime] (
  [pk_int] [int] NOT NULL,
  [comp_image_datetime] [image] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO