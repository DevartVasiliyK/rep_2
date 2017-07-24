CREATE TABLE [dbo].[P-2-_xml_varchar(30)] (
  [pk_int] [int] NOT NULL,
  [comp_xml_varchar(30)] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO