CREATE TABLE [dbo].[P-2-_xml_geometry] (
  [pk_int] [int] NOT NULL,
  [comp_xml_geometry] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO