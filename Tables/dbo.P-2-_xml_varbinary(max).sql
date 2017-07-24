CREATE TABLE [dbo].[P-2-_xml_varbinary(max)] (
  [pk_int] [int] NOT NULL,
  [comp_xml_varbinary(max)] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO