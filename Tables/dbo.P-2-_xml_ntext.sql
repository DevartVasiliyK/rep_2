CREATE TABLE [dbo].[P-2-_xml_ntext] (
  [pk_int] [int] NOT NULL,
  [comp_xml_ntext] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO