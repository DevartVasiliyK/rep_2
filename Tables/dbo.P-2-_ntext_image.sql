CREATE TABLE [dbo].[P-2-_ntext_image] (
  [pk_int] [int] NOT NULL,
  [comp_ntext_image] [ntext] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO