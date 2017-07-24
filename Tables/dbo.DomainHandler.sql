CREATE TABLE [dbo].[DomainHandler] (
  [Handler_ID] [int] IDENTITY,
  [Hostname] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
  [TargetURL] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
  [Title] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
  [Comments] [ntext] COLLATE Latin1_General_CI_AS NULL,
  [useFrame] [bit] NOT NULL CONSTRAINT [DF_DomainHandler_useFrame] DEFAULT (0),
  [TargetUrlNew] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
  CONSTRAINT [PK_DomainHandler] PRIMARY KEY CLUSTERED ([Handler_ID]) WITH (FILLFACTOR = 90)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_DefaultView', 0x02, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_Filter', NULL, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_FilterOnLoad', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_HideNewField', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_OrderBy', NULL, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_OrderByOn', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_OrderByOnLoad', 1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_Orientation', 0x00, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_TableMaxRecords', 10000, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_TotalsRow', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler'
GO

EXEC sys.sp_addextendedproperty N'MS_AggregateType', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Handler_ID'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnHidden', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Handler_ID'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnOrder', 1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Handler_ID'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnWidth', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Handler_ID'
GO

EXEC sys.sp_addextendedproperty N'MS_TextAlign', 0x00, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Handler_ID'
GO

EXEC sys.sp_addextendedproperty N'MS_AggregateType', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Hostname'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnHidden', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Hostname'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnOrder', 2, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Hostname'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnWidth', 3525, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Hostname'
GO

EXEC sys.sp_addextendedproperty N'MS_TextAlign', 0x00, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Hostname'
GO

EXEC sys.sp_addextendedproperty N'MS_AggregateType', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'TargetURL'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnHidden', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'TargetURL'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnOrder', 3, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'TargetURL'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnWidth', 5775, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'TargetURL'
GO

EXEC sys.sp_addextendedproperty N'MS_TextAlign', 0x00, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'TargetURL'
GO

EXEC sys.sp_addextendedproperty N'MS_AggregateType', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Title'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnHidden', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Title'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnOrder', 4, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Title'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnWidth', 3195, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Title'
GO

EXEC sys.sp_addextendedproperty N'MS_TextAlign', 0x00, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Title'
GO

EXEC sys.sp_addextendedproperty N'MS_AggregateType', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Comments'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnHidden', 0, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Comments'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnOrder', 5, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Comments'
GO

EXEC sys.sp_addextendedproperty N'MS_ColumnWidth', -1, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Comments'
GO

EXEC sys.sp_addextendedproperty N'MS_TextAlign', 0x00, 'SCHEMA', N'dbo', 'TABLE', N'DomainHandler', 'COLUMN', N'Comments'
GO