CREATE TABLE [dbo].[P-2-_xml_geography] (
  [pk_int] [int] NOT NULL,
  [comp_xml_geography] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO