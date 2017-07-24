CREATE TABLE [describer].[table_sparse] (
  [pk] [int] NOT NULL,
  [colnotsparse] [varchar](20) NULL,
  [col_sparse] [varchar](20) SPARSE NULL,
  [colgeom] [geometry] NULL,
  [xmlcol] [xml] NULL,
  [textcol] [varbinary](max) NULL,
  [textcol1] [char](1) NULL,
  CONSTRAINT [constr_name_for_FULL_TEXT_INDEX] PRIMARY KEY CLUSTERED ([pk])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO