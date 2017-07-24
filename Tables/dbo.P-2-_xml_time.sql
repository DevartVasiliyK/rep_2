CREATE TABLE [dbo].[P-2-_xml_time] (
  [pk_int] [int] NOT NULL,
  [comp_xml_time] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO