-- ============================================================
-- BASELINE: dbo.UspZeraEspelho
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspZeraEspelho]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[UspZeraEspelho] (    
    @CodPeriodoPagamento INT,    
    @idrota VARCHAR(50) NULL,    
    @cd_usr INT    
)    
AS    
BEGIN    
 
           
    /*
	Comentado por Saulo Barros em 17/02/2026 pois nenhuma dessas variaveis está sendo utilizada no update
	e quando passa no @idrota um texto (caso da shopee) da erro no select que gera valor na variavel @Motorista pois ela vai na tb_ml_rotas

    DECLARE    
        @IdTransportadora INT,    
        --@CodPeriodoPagamento INT = 2338,    
        --@idrota VARCHAR(50) = NULL,    
        --@cd_usr INT = 7, -- se receber valor NULL precisa    
        @data_inicial DATE,    
        @data_final DATE,    
        @clienteid INT,    
        @usuarioIrisys INT,    
        @Motorista VARCHAR(250),    
        @IdCliTransportadora INT,    
        @tipocontrato INT = NULL,    
        @agora DATETIME = GETDATE();    
    
    ----- Parâmetros de filtros    
    SET @data_inicial = (    
        SELECT pgp_dt_inicio    
        FROM [dbo].[tb_pgto_periodo] WITH (NOLOCK)    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    SET @data_final = (    
        SELECT pgp_dt_fim    
        FROM [dbo].[tb_pgto_periodo] WITH (NOLOCK)    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    IF @idrota IS NOT NULL    
    BEGIN    
        SET @Motorista = (    
            SELECT DISTINCT NomeMotorista    
            FROM tb_ml_rotas (NOLOCK)    
            WHERE idrota = @idrota    
        );    
    END;    
    
    SET @IdTransportadora = (    
        SELECT cli_id_logistics    
        FROM [tb_pgto_periodo] AS a (NOLOCK)    
        LEFT JOIN tb_clientes AS b (NOLOCK)    
            ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    SET @tipocontrato = (    
        SELECT pgp_cd_tipo_contratos    
        FROM [tb_pgto_periodo] AS a (NOLOCK)    
        LEFT JOIN tb_clientes AS b (NOLOCK)    
            ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    SET @IdCliTransportadora = (    
        SELECT lst_cd_lista    
        FROM tb_lista (NOLOCK)    
        WHERE lst_nm_lista = 'Clientes transportadoras'    
          AND lst_ds_label = 'Mercado Livre'    
          AND lst_cd_cliente IN (    
                SELECT pgp_cd_cliente    
                FROM [tb_pgto_periodo] AS a (NOLOCK)    
                LEFT JOIN tb_clientes AS b (NOLOCK)    
                    ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
                WHERE pgp_cd_periodo = @CodPeriodoPagamento    
          )    
    );    
    
    SET @clienteid = (    
        SELECT pgp_cd_cliente    
        FROM [tb_pgto_periodo] AS a (NOLOCK)    
        LEFT JOIN tb_clientes AS b (NOLOCK)    
            ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    DECLARE @Operacao INT = (    
        SELECT lst_cd_lista    
        FROM tb_lista WITH (NOLOCK)    
        WHERE lst_nm_lista = 'Operações Marketplace'    
          AND lst_ds_valor = 'LM'    
          AND lst_cd_cliente = @clienteid    
    );    
    
    ----- Parâmetros para cálculos    
    DECLARE @Kmselecionado1 VARCHAR(150) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'    
          AND prm_nm_parametro = 'Km a ser utilizado.'    
          AND prm_cod_cliente = 37    
    );    
    
    DECLARE @Kmselecionado2 VARCHAR(150) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'    
          AND prm_nm_parametro = 'Km a ser utilizado 2'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    DECLARE @MenorValorKm VARCHAR(5) = (    
        SELECT prm_ds_valor    
        FROM tb_parametros    
        WHERE prm_nm_parametro = 'Considerar menor valor entre KM'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    DECLARE @Veiculo VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Veiculo'    
          AND prm_cod_cliente = @clienteid    
          and prm_ds_categoria = 'Financeiro - Pagamentos'    
    );    
    
    -- Utiliza ponto ou parada    
    DECLARE @PontoOuParada VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Pontou ou Parada'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    -- Este parâmetro é a origem da parada    
    DECLARE @OrigemParada VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        -- O nome desta lista precisa mudar para "Parâmetros do financeiro - Origem Paradas"    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - QuantidadeParadas'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    -- Origem ponto    
    DECLARE @OrigemPonto VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        -- O nome desta lista precisa mudar para "Parâmetros do financeiro - Origem Pontos"    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - QuantidadePontos'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    DECLARE @DivisaoEspelho VARCHAR(50) = (    
        SELECT prm_ds_valor    
        FROM tb_parametros    
        WHERE prm_nm_parametro = 'Divisão  de espelho'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    -- Descontos de ponto ou parada    
    DECLARE @DescontaPontoPara VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Desconta Pacote'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    declare @UtilizaContrato int = (    
     select prm_ds_valor     
     from tb_parametros     
     where prm_ds_categoria = 'Financeiro - Pagamentos'    
     and prm_nm_parametro = 'Utiliza contrato'    
     and prm_cod_cliente = @clienteid    
 )    
    
	fim por Saulo Barros em 17/02/2026
	*/
    
    
    
    
   
    update	a
    set	    ppr_in_excluido = 1
        ,	ppr_dh_modificacao = getdate()
        ,	ppr_cd_usr_modificacao = 7  

    FROM    tb_pgto_periodo_rota as a  
    inner   join tb_pag_espelhos as b  
            on a.ppr_cd_motorista_nfs = mtn_cd_motorista_nfs  
    inner	join tb_veiculos as vei on a.ppr_ds_placa = vei.vei_ds_placa and vei_in_ativo = 1

    WHERE   ppr_cd_periodo = @CodPeriodoPagamento    
            and mtn_cd_status IN (34,228,38)    
            and (ppr_cd_rota  = @idrota OR @idrota IS NULL)
            -- Cadastro de veiculos que deleta no espelho
            and vei.vei_zerar_espelho = 1
      ;    
    
 
    
end 
GO
/****** Object:  DdlTrigger [AuditoriaDDLEventos]    Script Date: 14/09/2026 12:14:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [AuditoriaDDLEventos]
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE, 
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
    CREATE_INDEX, ALTER_INDEX, DROP_INDEX,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW, 
    CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION
AS
BEGIN
    SET NOCOUNT ON;

    -- Captura os dados do evento em formato XML
    DECLARE @data XML;
    SET @data = EVENTDATA();

    -- Inserir os dados capturados na tabela de auditoria
    INSERT INTO dbo.AuditoriaDDL (
        Evento,
        Esquema,
        Objeto,
        TipoObjeto,
        LoginUsuario,
        TSQL,
        XMLEvento
    )
    VALUES (
        @data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),  -- Tipo de evento
        @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(100)'), -- Nome do esquema
        @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'), -- Nome do objeto
        @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'), -- Tipo do objeto
        @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)'),  -- Login do usuário
        @data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'), -- TSQL executado
        @data -- XML completo do evento
    );
END;
GO
ENABLE TRIGGER [AuditoriaDDLEventos] ON DATABASE
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The major version number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The minor version number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The update level of the build. CU indicates a cumulative update. SP indicates a service pack. RTM indicates Release To Manufacturer. GDR indicates a General Distribution Release. QFE indicates Quick Fix Engineering (aka hotfix).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Branch'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'A link to the KB article for a version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Url'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date the version was publicly released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ReleaseDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date main stream Microsoft support ends for the version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MainstreamSupportEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date extended Microsoft support ends for the version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ExtendedSupportEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The major version name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionName'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The minor version name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionName'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'A reference for SQL Server major and minor versions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -288
         Left = 0
      End
      Begin Tables = 
         Begin Table = "r"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 340
            End
            DisplayFlags = 280
            TopColumn = 94
         End
         Begin Table = "receb"
            Begin Extent = 
               Top = 150
               Left = 38
               Bottom = 290
               Right = 316
            End
            DisplayFlags = 280
            TopColumn = 69
         End
         Begin Table = "amb"
            Begin Extent = 
               Top = 294
               Left = 38
               Bottom = 434
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "cli"
            Begin Extent = 
               Top = 438
               Left = 38
               Bottom = 578
               Right = 308
            End
            DisplayFlags = 280
            TopColumn = 41
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_rel_ambulancias'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_rel_ambulancias'
GO
USE [master]
GO
ALTER DATABASE [db_Irisys] SET  READ_WRITE 
GO
