CREATE TABLE [describer].[table_sparse_g] (
  [pk] [int] NOT NULL,
  [colnotsparse] [varchar](20) NULL,
  [col_sparse] [varchar](20) SPARSE NULL,
  [colgeom] [geography] NULL,
  [xmlcol] [xml] NULL,
  [textcol] [varbinary](max) NULL,
  [textcol1] [char](1) NULL,
  CONSTRAINT [pk] PRIMARY KEY CLUSTERED ([pk])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO