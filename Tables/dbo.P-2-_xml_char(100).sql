CREATE TABLE [dbo].[P-2-_xml_char(100)] (
  [pk_int] [int] NOT NULL,
  [comp_xml_char(100)] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO