CREATE TABLE [dbo].[P-2-_image_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_image_decimal(5,3)] [image] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO