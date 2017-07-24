CREATE TABLE [dbo].[P-2-_xml_nvarchar] (
  [pk_int] [int] NOT NULL,
  [comp_xml_nvarchar] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO