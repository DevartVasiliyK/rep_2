CREATE TABLE [dbo].[P-2-_image_varchar(max)] (
  [pk_int] [int] NOT NULL,
  [comp_image_varchar(max)] [image] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO