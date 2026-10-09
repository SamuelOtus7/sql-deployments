/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Modelo estrela da Fato DRE (pre-fatura ML + espelhos), inspirado
                 no modelo DRE Imediato (IMEDIATODW), corrigindo as armadilhas
                 la identificadas (transacao por recorte, indice cluster,
                 periodo por parametro, regras em cadastro e nao no codigo).
                 1) Dimensoes novas: tb_dim_visao, tb_dim_origem,
                    tb_dim_marketplace, tb_dim_dre_indicador,
                    tb_dim_dre_estrutura (por empresa), tb_dim_plano_contas.
                 2) Fato: tb_fato_dre (grao Empresa x Ano x Mes x Quinzena x
                    Marketplace x Base x Conta x Origem x Visao), cluster em
                    (Ano, Mes, CodCliente).
                 3) Apoio: tb_fin_dre_carga_log, tb_fin_dre_processamento
                    (workflow Orçado), tb_aud_dre (trilha de auditoria).
                 4) vw_fin_fato_dre (consumo) + sp_fin_dre_carga (idempotente
                    por Empresa x AnoMes, DELETE+INSERT dentro de transacao,
                    subtotais pre-calculados via GruposAgregadores).
                 5) Triggers de auditoria nas tabelas gerenciadas.
                 6) Backfill inicial: CodVisao=1 para todos os pares
                    CodCliente x AnoMes existentes em tb_fin_prefatura.
  Rollback     : scripts/rollback/2026/10/039_rollback_CU-86ahpqmf9_fato_dre.sql
  Objetos      : 6x tb_dim_*, tb_fato_dre, tb_fin_dre_carga_log,
                 tb_fin_dre_processamento, tb_aud_dre, vw_fin_fato_dre,
                 sp_fin_dre_carga, 7x trg_aud_*
  Dependencias : DimData, tb_clientes, tb_bases, tb_dra_marketplace,
                 tb_fin_prefatura(_descontos/_totais), tb_pag_espelhos,
                 tb_pgto_periodo, tb_fin_cadastro_impostos
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fato_dre'))
        THROW 50001, 'Tabela dbo.tb_fato_dre ja existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.DimData'))
        THROW 50002, 'Tabela dbo.DimData nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fin_prefatura_totais'))
        THROW 50003, 'Tabela dbo.tb_fin_prefatura_totais nao encontrada (aplique CU-86ahpqmf9/038 antes).', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_espelhos'))
        THROW 50004, 'Tabela dbo.tb_pag_espelhos nao encontrada.', 1;
    PRINT 'Pre-checks OK.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. DIMENSOES DE DOMINIO (visao, origem, marketplace)
--============================================================================
CREATE TABLE dbo.tb_dim_visao (
    CodVisao   smallint     NOT NULL,
    Descricao  varchar(30)  NOT NULL,
    InAtivo    bit          NOT NULL CONSTRAINT DF_dim_visao_ativo DEFAULT (1),
    CONSTRAINT PK_dim_visao PRIMARY KEY (CodVisao)
);

CREATE TABLE dbo.tb_dim_origem (
    CodOrigem  smallint     IDENTITY(1,1) NOT NULL,
    Descricao  varchar(40)  NOT NULL,
    InAtivo    bit          NOT NULL CONSTRAINT DF_dim_origem_ativo DEFAULT (1),
    CONSTRAINT PK_dim_origem PRIMARY KEY (CodOrigem),
    CONSTRAINT UQ_dim_origem_desc UNIQUE (Descricao)
);

CREATE TABLE dbo.tb_dim_marketplace (
    CodMarketplace  smallint     IDENTITY(1,1) NOT NULL,
    NomeMarketplace varchar(60)  NOT NULL,
    InAtivo         bit          NOT NULL CONSTRAINT DF_dim_mkt_ativo DEFAULT (1),
    CONSTRAINT PK_dim_marketplace PRIMARY KEY (CodMarketplace),
    CONSTRAINT UQ_dim_marketplace_nome UNIQUE (NomeMarketplace)
);
GO

-- Seeds de dominio
INSERT INTO dbo.tb_dim_visao (CodVisao, Descricao) VALUES (1, 'Realizado'), (2, 'Orcado');
INSERT INTO dbo.tb_dim_origem (Descricao) VALUES
    ('PREFATURA'), ('DESCONTO'), ('ESPELHO'), ('MANUAL'), ('TOTALIZADOR'), ('OVERHEAD');

-- Marketplace: dominio canonico tb_dra_marketplace + valores livres de tb_bases
INSERT INTO dbo.tb_dim_marketplace (NomeMarketplace)
SELECT mkp_nm_marketplace FROM dbo.tb_dra_marketplace WITH (NOLOCK)
UNION
SELECT DISTINCT bss_ds_marketplace FROM dbo.tb_bases WITH (NOLOCK)
WHERE bss_ds_marketplace IS NOT NULL AND bss_ds_marketplace <> '';
GO

--============================================================================
-- 3. DIMENSOES DRE (indicador, estrutura por empresa, plano de contas)
--============================================================================
CREATE TABLE dbo.tb_dim_dre_indicador (
    SkIndicador   int          IDENTITY(1,1) NOT NULL,
    CodIndicador  varchar(20)  NOT NULL,
    NomeIndicador varchar(150) NOT NULL,
    Natureza      char(1)      NOT NULL,   -- C receita/+, D despesa/-
    InAtivo       bit          NOT NULL CONSTRAINT DF_dim_ind_ativo DEFAULT (1),
    CONSTRAINT PK_dim_dre_indicador PRIMARY KEY (SkIndicador),
    CONSTRAINT UQ_dim_dre_indicador_cod UNIQUE (CodIndicador)
);

CREATE TABLE dbo.tb_dim_dre_estrutura (
    SkGrupo            int           IDENTITY(1,1) NOT NULL,
    CodCliente         int           NOT NULL,   -- arvore por empresa
    DescricaoEstrutura varchar(60)   NOT NULL CONSTRAINT DF_dim_dre_est_desc DEFAULT ('Padrao'),
    NomeGrupo          varchar(150)  NOT NULL,
    Ordem              int           NOT NULL,
    SkIndicador        int           NULL,
    Negrito            bit           NOT NULL CONSTRAINT DF_dim_dre_est_neg DEFAULT (0),
    GruposAgregadores  varchar(1000) NULL,   -- '' = folha; lista = subtotal
    InAtivo            bit           NOT NULL CONSTRAINT DF_dim_dre_est_ativo DEFAULT (1),
    CONSTRAINT PK_dim_dre_estrutura PRIMARY KEY (SkGrupo),
    CONSTRAINT FK_dim_dre_est_ind FOREIGN KEY (SkIndicador)
        REFERENCES dbo.tb_dim_dre_indicador (SkIndicador)
);

CREATE TABLE dbo.tb_dim_plano_contas (
    CodContaContabil varchar(20)  NOT NULL,
    ContaContabil    varchar(150) NOT NULL,
    Categoria        varchar(100) NULL,
    Subcategoria     varchar(100) NULL,
    SkIndicador      int          NULL,
    CodCliente       int          NOT NULL CONSTRAINT DF_dim_pc_cli DEFAULT (0), -- 0 = global; >0 = override por empresa
    InAtivo          bit          NOT NULL CONSTRAINT DF_dim_pc_ativo DEFAULT (1),
    CONSTRAINT PK_dim_plano_contas PRIMARY KEY (CodContaContabil, CodCliente),
    CONSTRAINT FK_dim_pc_ind FOREIGN KEY (SkIndicador)
        REFERENCES dbo.tb_dim_dre_indicador (SkIndicador)
);
GO

--============================================================================
-- 4. FATO + TABELAS DE APOIO (log, processamento orcado, auditoria)
--============================================================================
CREATE TABLE dbo.tb_fato_dre (
    IdFato           bigint        IDENTITY(1,1) NOT NULL,
    SkData           int           NOT NULL,
    Data             date          NOT NULL,
    Ano              int           NOT NULL,
    Mes              tinyint       NOT NULL,
    Quinzena         tinyint       NOT NULL,
    CodCliente       int           NOT NULL,
    IdTransportadora bigint        NOT NULL,
    CodMarketplace   smallint      NULL,
    CodBase          int           NULL,
    CodContaContabil varchar(20)   NOT NULL,
    SkIndicador      int           NULL,
    CodOrigem        smallint      NOT NULL,
    CodVisao         smallint      NOT NULL,
    IdReferencia     varchar(50)   NULL,
    IdTransacao      varchar(60)   NULL,
    Valor            decimal(18,2) NOT NULL,
    DataCarga        datetime      NOT NULL CONSTRAINT DF_fato_dre_carga DEFAULT SYSDATETIME(),
    CONSTRAINT PK_tb_fato_dre PRIMARY KEY NONCLUSTERED (IdFato),
    CONSTRAINT FK_fato_dim_data       FOREIGN KEY (SkData)           REFERENCES dbo.DimData (SkData),
    CONSTRAINT FK_fato_cliente        FOREIGN KEY (CodCliente)       REFERENCES dbo.tb_clientes (cli_cd_codigo_cliente),
    CONSTRAINT FK_fato_marketplace    FOREIGN KEY (CodMarketplace)   REFERENCES dbo.tb_dim_marketplace (CodMarketplace),
    CONSTRAINT FK_fato_base           FOREIGN KEY (CodBase)          REFERENCES dbo.tb_bases (bss_cd_base),
    CONSTRAINT FK_fato_indicador      FOREIGN KEY (SkIndicador)      REFERENCES dbo.tb_dim_dre_indicador (SkIndicador),
    CONSTRAINT FK_fato_origem         FOREIGN KEY (CodOrigem)        REFERENCES dbo.tb_dim_origem (CodOrigem),
    CONSTRAINT FK_fato_visao          FOREIGN KEY (CodVisao)         REFERENCES dbo.tb_dim_visao (CodVisao)
);
CREATE CLUSTERED INDEX IX_tb_fato_dre_periodo ON dbo.tb_fato_dre (Ano, Mes, CodCliente);

CREATE TABLE dbo.tb_fin_dre_carga_log (
    IdCargaLog  bigint       IDENTITY(1,1) NOT NULL,
    Ano         int          NOT NULL,
    Mes         tinyint      NOT NULL,
    CodCliente  int          NOT NULL,
    CodOrigem   smallint     NULL,
    CodVisao    smallint     NOT NULL,
    QtLinhas    int          NOT NULL,
    DhInicio    datetime     NOT NULL,
    DhFim       datetime     NOT NULL,
    Status      varchar(20)  NOT NULL,
    Erro        varchar(2000) NULL,
    CONSTRAINT PK_dre_carga_log PRIMARY KEY (IdCargaLog)
);

CREATE TABLE dbo.tb_fin_dre_processamento (
    CodCliente   int         NOT NULL,
    Ano          int         NOT NULL,
    Mes          tinyint     NOT NULL,
    CodVisao     smallint    NOT NULL,
    Status       varchar(20) NOT NULL,   -- SIMULACAO | PROCESSADO
    DhGeracao    datetime    NOT NULL CONSTRAINT DF_dre_proc_geracao DEFAULT SYSDATETIME(),
    DhProcessado datetime    NULL,
    UsuarioApp   varchar(100) NULL,
    CONSTRAINT PK_dre_processamento PRIMARY KEY (CodCliente, Ano, Mes, CodVisao)
);

CREATE TABLE dbo.tb_aud_dre (
    IdAuditoria   bigint       IDENTITY(1,1) NOT NULL,
    DhEvento      datetime     NOT NULL CONSTRAINT DF_aud_dre_dh DEFAULT SYSDATETIME(),
    Tabela        varchar(60)  NOT NULL,
    Operacao      char(1)      NOT NULL,   -- I | U | D
    ChaveRegistro varchar(200) NOT NULL,
    Campo         varchar(60)  NULL,       -- reservado p/ log por coluna (app)
    ValorAntigo   nvarchar(max) NULL,      -- JSON da linha (deleted)
    ValorNovo     nvarchar(max) NULL,      -- JSON da linha (inserted)
    UsuarioApp    varchar(100) NULL,       -- quem editou na tela
    UsuarioDb     varchar(100) NOT NULL CONSTRAINT DF_aud_dre_user DEFAULT SUSER_SNAME(),
    Origem        varchar(40)  NOT NULL CONSTRAINT DF_aud_dre_origem DEFAULT 'SQL',
    CONSTRAINT PK_aud_dre PRIMARY KEY (IdAuditoria)
);
GO

--============================================================================
-- 5. SEEDS — indicadores, plano de contas, estrutura padrao COOMAP (63)
--============================================================================
INSERT INTO dbo.tb_dim_dre_indicador (CodIndicador, NomeIndicador, Natureza) VALUES
    ('RB-SERV',  'Subtotal de servicos',              'C'),
    ('RB-ADIC',  'Subtotal de adicionais',            'C'),
    ('DED-GLOSA','Ajuste/glosa ML',                   'D'),
    ('DED-LOST', 'Subtotal de Lost Packages Penalty', 'D'),
    ('DED-PNR',  'Subtotal de penalidades (PNR)',     'D'),
    ('DED-NV',   'Subtotal de Vehicle Daily Not Visited','D'),
    ('CT-MOT',   'Custo de motorista - pagamento NFS','D'),
    ('CT-IMP',   'Imposto / Tributos',                'D'),
    ('CT-SAL',   'Salario e Encargos',                'D'),
    ('CT-PESS',  'Gastos com Pessoal',                'D'),
    ('CT-INS',   'Insumos e Lubrificantes',           'D'),
    ('CT-ABAS',  'Custo Abastecimento (Combustiveis)','D'),
    ('CT-LUZ',   'Energia Eletrica (Luz)',            'D'),
    ('CT-ALUG',  'Aluguel Galpao',                    'D'),
    ('CT-MAN',   'Manutencao',                        'D'),
    ('CT-TERC',  'Servicos de Terceiros',             'D'),
    ('DES-OP',   'Despesas Operacionais',             'D'),
    ('DEPREC',   'Depreciacao',                       'D'),
    ('AMORT',    'Amortizacao',                       'D'),
    ('ST-RB',    'RECEITA BRUTA',                     'C'),
    ('ST-DED',   'DEDUCOES DA RECEITA',               'D'),
    ('ST-RL',    'RECEITA LIQUIDA',                   'C'),
    ('ST-CUST',  'CUSTOS OPERACIONAIS',               'D'),
    ('ST-LB',    'LUCRO BRUTO',                       'C'),
    ('ST-EBITDA','EBITDA',                            'C'),
    ('ST-LOP',   'LUCRO OPERACIONAL',                 'C'),
    ('ST-LL',    'LUCRO LIQUIDO',                     'C');
GO

INSERT INTO dbo.tb_dim_plano_contas (CodContaContabil, ContaContabil, Categoria, Subcategoria, SkIndicador)
SELECT cod, nome, cat, sub, i.SkIndicador
FROM (VALUES
    ('4.1.01','Receita de servicos ML','Receita','Servicos',      'RB-SERV'),
    ('4.1.02','Receita adicional (paradas/enderecos)','Receita','Adicionais','RB-ADIC'),
    ('4.2.01','Ajuste/glosa pre-fatura ML','Deducao','Glosa',     'DED-GLOSA'),
    ('4.2.02','Penalidade Lost Packages','Deducao','Penalidade',  'DED-LOST'),
    ('4.2.03','Penalidade PNR','Deducao','Penalidade',            'DED-PNR'),
    ('4.2.04','Vehicle Daily Not Visited','Deducao','Penalidade', 'DED-NV'),
    ('5.1.01','Pagamento de motoristas (NFS)','Custo','Motorista','CT-MOT'),
    ('5.2.01','Impostos (ISS/Comercial/Gestao)','Custo','Imposto','CT-IMP'),
    ('5.3.01','Salario e encargos','Custo','Pessoal',             'CT-SAL'),
    ('5.3.02','Gastos com pessoal','Custo','Pessoal',             'CT-PESS'),
    ('5.3.03','Insumos e lubrificantes','Custo','Insumos',        'CT-INS'),
    ('5.3.04','Abastecimento','Custo','Combustivel',              'CT-ABAS'),
    ('5.3.05','Energia eletrica','Custo','Utilidades',            'CT-LUZ'),
    ('5.3.06','Aluguel galpao','Custo','Ocupacao',                'CT-ALUG'),
    ('5.3.07','Manutencao','Custo','Frota',                      'CT-MAN'),
    ('5.3.08','Servicos de terceiros','Custo','Terceiros',        'CT-TERC'),
    ('5.4.01','Despesas operacionais','Despesa','Operacional',    'DES-OP'),
    ('5.5.01','Depreciacao','Despesa','Depreciacao',              'DEPREC'),
    ('5.5.02','Amortizacao','Despesa','Amortizacao',              'AMORT'),
    ('TOTAL','Totalizador (linha sintetica)','Sintetico','Total', NULL)
) v(cod, nome, cat, sub, ind)
LEFT JOIN dbo.tb_dim_dre_indicador i ON i.CodIndicador = v.ind;
GO

-- Estrutura padrao da empresa 63 (COOMAP) — espelha o DRE do relatorio
INSERT INTO dbo.tb_dim_dre_estrutura (CodCliente, NomeGrupo, Ordem, SkIndicador, Negrito, GruposAgregadores)
SELECT 63, v.grupo, v.ordem, i.SkIndicador, v.neg, v.agreg
FROM (VALUES
    ('RECEITA BRUTA',         1,  'ST-RB',    1, 'SERVICOS,ADICIONAIS,SUBTOTAL PREFATURA,GLOSA,PEN LOST,PEN PNR,PEN NV'),
    ('SERVICOS',              2,  'RB-SERV',  0, NULL),
    ('ADICIONAIS',            3,  'RB-ADIC',  0, NULL),
    ('SUBTOTAL PREFATURA',    4,  NULL,       0, NULL),
    ('GLOSA',                 5,  'DED-GLOSA',0, NULL),
    ('PEN LOST',              6,  'DED-LOST', 0, NULL),
    ('PEN PNR',               7,  'DED-PNR',  0, NULL),
    ('PEN NV',                8,  'DED-NV',   0, NULL),
    ('DEDUCOES DA RECEITA',   9,  'ST-DED',   1, 'PGTO MOTORISTA'),
    ('PGTO MOTORISTA',        10, 'CT-MOT',   0, NULL),
    ('RECEITA LIQUIDA',       11, 'ST-RL',    1, 'RECEITA BRUTA,DEDUCOES DA RECEITA'),
    ('CUSTOS OPERACIONAIS',   12, 'ST-CUST',  1, 'SALARIO,PESSOAL,INSUMOS,ABASTECIMENTO,LUZ,ALUGUEL,MANUTENCAO,TERCEIROS'),
    ('SALARIO',               13, 'CT-SAL',   0, NULL),
    ('PESSOAL',               14, 'CT-PESS',  0, NULL),
    ('INSUMOS',               15, 'CT-INS',   0, NULL),
    ('ABASTECIMENTO',         16, 'CT-ABAS',  0, NULL),
    ('LUZ',                   17, 'CT-LUZ',   0, NULL),
    ('ALUGUEL',               18, 'CT-ALUG',  0, NULL),
    ('MANUTENCAO',            19, 'CT-MAN',   0, NULL),
    ('TERCEIROS',             20, 'CT-TERC',  0, NULL),
    ('LUCRO BRUTO',           21, 'ST-LB',    1, 'RECEITA LIQUIDA,CUSTOS OPERACIONAIS'),
    ('DESPESAS OPERACIONAIS', 22, 'DES-OP',   0, NULL),
    ('EBITDA',                23, 'ST-EBITDA',1, 'LUCRO BRUTO,DESPESAS OPERACIONAIS'),
    ('DEPRECIACAO',           24, 'DEPREC',   0, NULL),
    ('AMORTIZACAO',           25, 'AMORT',    0, NULL),
    ('LUCRO OPERACIONAL',     26, 'ST-LOP',   1, 'EBITDA,DEPRECIACAO,AMORTIZACAO'),
    ('IMPOSTOS',              27, 'CT-IMP',   0, NULL),
    ('LUCRO LIQUIDO',         28, 'ST-LL',    1, 'LUCRO OPERACIONAL,IMPOSTOS')
) v(grupo, ordem, ind, neg, agreg)
LEFT JOIN dbo.tb_dim_dre_indicador i ON i.CodIndicador = v.ind;
GO

--============================================================================
-- 6. VIEW DE CONSUMO
--============================================================================
EXEC('
CREATE VIEW dbo.vw_fin_fato_dre AS
SELECT
    f.IdFato, f.Data, f.Ano, f.Mes, f.Quinzena,
    f.CodCliente, c.cli_ds_nome AS Empresa, f.IdTransportadora,
    mk.NomeMarketplace AS Marketplace,
    b.bss_ds_sigla AS Base, b.bss_ds_nome AS NomeBase,
    pc.CodContaContabil, pc.ContaContabil,
    i.CodIndicador, i.NomeIndicador,
    o.Descricao AS Origem,
    vs.Descricao AS Visao,
    f.IdReferencia, f.IdTransacao,
    f.Valor, f.DataCarga
FROM dbo.tb_fato_dre f
JOIN dbo.tb_clientes c      WITH (NOLOCK) ON c.cli_cd_codigo_cliente = f.CodCliente
JOIN dbo.tb_dim_origem o    WITH (NOLOCK) ON o.CodOrigem = f.CodOrigem
JOIN dbo.tb_dim_visao vs    WITH (NOLOCK) ON vs.CodVisao = f.CodVisao
LEFT JOIN dbo.tb_dim_marketplace mk WITH (NOLOCK) ON mk.CodMarketplace = f.CodMarketplace
LEFT JOIN dbo.tb_bases b            WITH (NOLOCK) ON b.bss_cd_base = f.CodBase
OUTER APPLY (
    SELECT TOP 1 pc2.CodContaContabil, pc2.ContaContabil
    FROM dbo.tb_dim_plano_contas pc2 WITH (NOLOCK)
    WHERE pc2.CodContaContabil = f.CodContaContabil
      AND pc2.CodCliente IN (0, f.CodCliente) AND pc2.InAtivo = 1
    ORDER BY pc2.CodCliente DESC
) pc
LEFT JOIN dbo.tb_dim_dre_indicador i WITH (NOLOCK) ON i.SkIndicador = f.SkIndicador
');
GO

--============================================================================
-- 7. PROCEDURE DE CARGA — sp_fin_dre_carga
--    Idempotente por (CodCliente, Ano, Mes[, Quinzena]) e CodVisao=1.
--    Recria: PREFATURA, DESCONTO (penalidades + glosa), ESPELHO e TOTALIZADOR.
--============================================================================
EXEC('
CREATE PROCEDURE dbo.sp_fin_dre_carga
    @CodCliente int,
    @Ano        int,
    @Mes        tinyint,
    @Quinzena   tinyint = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @dhIni datetime = SYSDATETIME();
    DECLARE @IdTransportadora bigint;
    DECLARE @orgPref smallint, @orgDesc smallint, @orgEsp smallint, @orgTot smallint;
    DECLARE @qt int = 0;

    SELECT @IdTransportadora = cli_id_logistics
    FROM dbo.tb_clientes WITH (NOLOCK)
    WHERE cli_cd_codigo_cliente = @CodCliente;

    SELECT @orgPref = CodOrigem FROM dbo.tb_dim_origem WHERE Descricao = ''PREFATURA'';
    SELECT @orgDesc = CodOrigem FROM dbo.tb_dim_origem WHERE Descricao = ''DESCONTO'';
    SELECT @orgEsp  = CodOrigem FROM dbo.tb_dim_origem WHERE Descricao = ''ESPELHO'';
    SELECT @orgTot  = CodOrigem FROM dbo.tb_dim_origem WHERE Descricao = ''TOTALIZADOR'';

    IF @IdTransportadora IS NULL
        THROW 50100, ''CodCliente sem cli_id_logistics em tb_clientes.'', 1;

    BEGIN TRY
        BEGIN TRAN;

        -- Recorte a recriar: visao Realizado, origens gerenciadas pela proc
        DELETE FROM dbo.tb_fato_dre
        WHERE CodCliente = @CodCliente AND Ano = @Ano AND Mes = @Mes
          AND CodVisao = 1
          AND CodOrigem IN (@orgPref, @orgDesc, @orgEsp, @orgTot)
          AND (@Quinzena IS NULL OR Quinzena = @Quinzena);

        ---------------------------------------------------------------
        -- a) PREFATURA: servicos (4.1.01) e adicionais (4.1.02)
        --    marketplace/base: ServiceCenter -> tb_bases.bss_ds_sigla
        ---------------------------------------------------------------
        INSERT INTO dbo.tb_fato_dre
            (SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
             CodMarketplace, CodBase, CodContaContabil, SkIndicador,
             CodOrigem, CodVisao, IdReferencia, IdTransacao, Valor)
        SELECT
            dd.SkData,
            DATEFROMPARTS(f.Ano, f.Mes, CASE WHEN f.Quinzena = 1 THEN 1 ELSE 16 END),
            f.Ano, f.Mes, f.Quinzena, @CodCliente, @IdTransportadora,
            mk.CodMarketplace, b.bss_cd_base,
            pc.CodContaContabil, pc.SkIndicador,
            @orgPref, 1, f.IdRota, NULL,
            CASE WHEN pc.CodContaContabil = ''4.1.01''
                 THEN SUM(CONVERT(decimal(18,2), f.Total))
                 ELSE SUM(CONVERT(decimal(18,2), f.VLParada)) END
        FROM dbo.tb_fin_prefatura f WITH (NOLOCK)
        CROSS JOIN (VALUES (''4.1.01''), (''4.1.02'')) ct(conta)
        JOIN dbo.tb_dim_plano_contas pc ON pc.CodContaContabil = ct.conta
                                       AND pc.CodCliente = 0 AND pc.InAtivo = 1
        JOIN dbo.DimData dd ON dd.Data =
            DATEFROMPARTS(f.Ano, f.Mes, CASE WHEN f.Quinzena = 1 THEN 1 ELSE 16 END)
        OUTER APPLY (
            SELECT TOP 1 b2.bss_cd_base, b2.bss_ds_marketplace
            FROM dbo.tb_bases b2 WITH (NOLOCK)
            WHERE b2.bss_ds_sigla = f.ServiceCenter AND b2.bss_in_excluido = 0
            ORDER BY b2.bss_cd_base
        ) b
        LEFT JOIN dbo.tb_dim_marketplace mk WITH (NOLOCK)
            ON mk.NomeMarketplace = b.bss_ds_marketplace
        WHERE f.IdTransportadora = @IdTransportadora
          AND f.Ano = @Ano AND f.Mes = @Mes
          AND (@Quinzena IS NULL OR f.Quinzena = @Quinzena)
        GROUP BY dd.SkData, f.Ano, f.Mes, f.Quinzena, mk.CodMarketplace,
                 b.bss_cd_base, pc.CodContaContabil, pc.SkIndicador, f.IdRota
        HAVING CASE WHEN pc.CodContaContabil = ''4.1.01''
                    THEN SUM(CONVERT(decimal(18,2), f.Total))
                    ELSE SUM(CONVERT(decimal(18,2), f.VLParada)) END IS NOT NULL;
        SET @qt = @qt + @@ROWCOUNT;

        ---------------------------------------------------------------
        -- b) DESCONTO: penalidades por tipo (valor negativo)
        ---------------------------------------------------------------
        INSERT INTO dbo.tb_fato_dre
            (SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
             CodContaContabil, SkIndicador, CodOrigem, CodVisao,
             IdReferencia, Valor)
        SELECT
            dd.SkData,
            DATEFROMPARTS(x.Ano, x.Mes, CASE WHEN x.Quinzena = 1 THEN 1 ELSE 16 END),
            x.Ano, x.Mes, x.Quinzena, @CodCliente, @IdTransportadora,
            pc.CodContaContabil, pc.SkIndicador, @orgDesc, 1,
            NULL, -SUM(ABS(CONVERT(decimal(18,2), x.Total)))
        FROM (
            SELECT IdTransportadora, Ano, Mes, Quinzena, Descricao, Total
            FROM dbo.tb_fin_prefatura_descontos WITH (NOLOCK)
            UNION ALL
            SELECT IdTransportadora, Ano, Mes, Quinzena, Descricao, Total
            FROM dbo.tb_fin_prefatura_descontos_not_visited WITH (NOLOCK)
        ) x
        JOIN dbo.tb_dim_plano_contas pc ON pc.CodCliente = 0 AND pc.InAtivo = 1
            AND pc.CodContaContabil = CASE
                WHEN x.Descricao LIKE ''Lost Packages%''            THEN ''4.2.02''
                WHEN x.Descricao LIKE ''Pnr Packages%''             THEN ''4.2.03''
                WHEN x.Descricao LIKE ''Vehicle Daily Not Visited%'' THEN ''4.2.04''
            END
        JOIN dbo.DimData dd ON dd.Data =
            DATEFROMPARTS(x.Ano, x.Mes, CASE WHEN x.Quinzena = 1 THEN 1 ELSE 16 END)
        WHERE x.IdTransportadora = @IdTransportadora
          AND x.Ano = @Ano AND x.Mes = @Mes
          AND (@Quinzena IS NULL OR x.Quinzena = @Quinzena)
        GROUP BY dd.SkData, x.Ano, x.Mes, x.Quinzena, pc.CodContaContabil, pc.SkIndicador
        HAVING SUM(ABS(CONVERT(decimal(18,2), x.Total))) IS NOT NULL;
        SET @qt = @qt + @@ROWCOUNT;

        ---------------------------------------------------------------
        -- c) ESPELHO: pagamento motorista (5.1.01, negativo)
        --    mes = pgp_dt_inicio do periodo de pagamento
        ---------------------------------------------------------------
        INSERT INTO dbo.tb_fato_dre
            (SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
             CodMarketplace, CodBase, CodContaContabil, SkIndicador,
             CodOrigem, CodVisao, IdReferencia, IdTransacao, Valor)
        SELECT
            dd.SkData,
            DATEFROMPARTS(YEAR(p.pgp_dt_inicio), MONTH(p.pgp_dt_inicio),
                          CASE WHEN DAY(p.pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END),
            YEAR(p.pgp_dt_inicio), MONTH(p.pgp_dt_inicio),
            CASE WHEN DAY(p.pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END,
            @CodCliente, @IdTransportadora,
            mk.CodMarketplace, b.bss_cd_base,
            ''5.1.01'', (SELECT SkIndicador FROM dbo.tb_dim_plano_contas
                        WHERE CodContaContabil = ''5.1.01'' AND CodCliente = 0),
            @orgEsp, 1, CONVERT(varchar(50), p.pgp_cd_periodo), NULL,
            -SUM(CONVERT(decimal(18,2), e.mtn_vl_nfs))
        FROM dbo.tb_pag_espelhos e WITH (NOLOCK)
        JOIN dbo.tb_pgto_periodo p WITH (NOLOCK)
            ON p.pgp_cd_periodo = e.mtn_cd_pgto_periodo
        JOIN dbo.DimData dd ON dd.Data =
            DATEFROMPARTS(YEAR(p.pgp_dt_inicio), MONTH(p.pgp_dt_inicio),
                          CASE WHEN DAY(p.pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END)
        LEFT JOIN dbo.tb_bases b WITH (NOLOCK) ON b.bss_cd_base = e.mtn_cd_base
        LEFT JOIN dbo.tb_dim_marketplace mk WITH (NOLOCK)
            ON mk.NomeMarketplace = b.bss_ds_marketplace
        WHERE e.mtn_in_excluido = 0
          AND e.mtn_cod_cliente = @CodCliente
          AND YEAR(p.pgp_dt_inicio) = @Ano AND MONTH(p.pgp_dt_inicio) = @Mes
          AND (@Quinzena IS NULL
               OR (CASE WHEN DAY(p.pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END) = @Quinzena)
        GROUP BY dd.SkData, YEAR(p.pgp_dt_inicio), MONTH(p.pgp_dt_inicio),
                 CASE WHEN DAY(p.pgp_dt_inicio) <= 15 THEN 1 ELSE 2 END,
                 mk.CodMarketplace, b.bss_cd_base, p.pgp_cd_periodo
        HAVING SUM(CONVERT(decimal(18,2), e.mtn_vl_nfs)) IS NOT NULL;
        SET @qt = @qt + @@ROWCOUNT;

        ---------------------------------------------------------------
        -- d) GLOSA: ajuste ML (4.2.01, negativo) de tb_fin_prefatura_totais
        ---------------------------------------------------------------
        INSERT INTO dbo.tb_fato_dre
            (SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
             CodContaContabil, SkIndicador, CodOrigem, CodVisao,
             IdReferencia, Valor)
        SELECT
            dd.SkData,
            DATEFROMPARTS(t.Ano, t.Mes, CASE WHEN t.Quinzena = 1 THEN 1 ELSE 16 END),
            t.Ano, t.Mes, t.Quinzena, @CodCliente, @IdTransportadora,
            ''4.2.01'', (SELECT SkIndicador FROM dbo.tb_dim_plano_contas
                        WHERE CodContaContabil = ''4.2.01'' AND CodCliente = 0),
            @orgDesc, 1, t.IDPrefatura, -SUM(t.GlosaPrefatura)
        FROM dbo.tb_fin_prefatura_totais t WITH (NOLOCK)
        JOIN dbo.DimData dd ON dd.Data =
            DATEFROMPARTS(t.Ano, t.Mes, CASE WHEN t.Quinzena = 1 THEN 1 ELSE 16 END)
        WHERE t.IdTransportadora = @IdTransportadora
          AND t.Ano = @Ano AND t.Mes = @Mes
          AND (@Quinzena IS NULL OR t.Quinzena = @Quinzena)
          AND t.GlosaPrefatura IS NOT NULL AND t.GlosaPrefatura <> 0
        GROUP BY dd.SkData, t.Ano, t.Mes, t.Quinzena, t.IDPrefatura;
        SET @qt = @qt + @@ROWCOUNT;

        ---------------------------------------------------------------
        -- e) TOTALIZADOR: subtotais da arvore da empresa (GruposAgregadores)
        ---------------------------------------------------------------
        ;WITH grp AS (
            SELECT SkGrupo, NomeGrupo, SkIndicador, GruposAgregadores
            FROM dbo.tb_dim_dre_estrutura WITH (NOLOCK)
            WHERE CodCliente = @CodCliente AND InAtivo = 1
        ),
        map AS (
            SELECT p.SkGrupo AS SkPai, f.SkGrupo AS SkFilho
            FROM grp p
            JOIN grp f ON f.SkGrupo <> p.SkGrupo
                AND p.GruposAgregadores IS NOT NULL AND p.GruposAgregadores <> ''''
                AND CHARINDEX(f.NomeGrupo, p.GruposAgregadores) > 0
        ),
        tree AS (
            SELECT SkPai AS Raiz, SkFilho FROM map
            UNION ALL
            SELECT t.Raiz, m.SkFilho FROM tree t JOIN map m ON m.SkPai = t.SkFilho
        )
        INSERT INTO dbo.tb_fato_dre
            (SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
             CodContaContabil, SkIndicador, CodOrigem, CodVisao,
             IdReferencia, Valor)
        SELECT
            dd.SkData,
            DATEFROMPARTS(@Ano, @Mes, CASE WHEN f.Quinzena = 1 THEN 1 ELSE 16 END),
            @Ano, @Mes, f.Quinzena, @CodCliente, @IdTransportadora,
            ''TOTAL'', raiz.SkIndicador, @orgTot, 1,
            ''TOT:'' + CONVERT(varchar(10), raiz.SkGrupo),
            SUM(f.Valor)
        FROM tree
        JOIN grp raiz  ON raiz.SkGrupo = tree.Raiz
        JOIN grp folha ON folha.SkGrupo = tree.SkFilho
            AND (folha.GruposAgregadores IS NULL OR folha.GruposAgregadores = '''')
        JOIN dbo.tb_fato_dre f ON f.SkIndicador = folha.SkIndicador
            AND f.CodCliente = @CodCliente AND f.Ano = @Ano AND f.Mes = @Mes
            AND f.CodVisao = 1 AND f.CodOrigem <> @orgTot
        JOIN dbo.DimData dd ON dd.Data =
            DATEFROMPARTS(@Ano, @Mes, CASE WHEN f.Quinzena = 1 THEN 1 ELSE 16 END)
        GROUP BY dd.SkData, f.Quinzena, raiz.SkGrupo, raiz.SkIndicador;
        SET @qt = @qt + @@ROWCOUNT;

        ---------------------------------------------------------------
        -- f) Log de carga
        ---------------------------------------------------------------
        INSERT INTO dbo.tb_fin_dre_carga_log
            (Ano, Mes, CodCliente, CodOrigem, CodVisao, QtLinhas, DhInicio, DhFim, Status)
        VALUES (@Ano, @Mes, @CodCliente, NULL, 1, @qt, @dhIni, SYSDATETIME(), ''OK'');

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        INSERT INTO dbo.tb_fin_dre_carga_log
            (Ano, Mes, CodCliente, CodOrigem, CodVisao, QtLinhas, DhInicio, DhFim, Status, Erro)
        VALUES (@Ano, @Mes, @CodCliente, NULL, 1, 0, @dhIni, SYSDATETIME(), ''ERRO'', ERROR_MESSAGE());
        THROW;
    END CATCH
END
');
GO

--============================================================================
-- 8. TRIGGERS DE AUDITORIA (tabelas gerenciadas + simulacao Orcado na fato)
--============================================================================
EXEC('
CREATE TRIGGER dbo.trg_aud_dim_plano_contas ON dbo.tb_dim_plano_contas
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_dim_plano_contas'',
           CASE WHEN i.CodContaContabil IS NOT NULL AND d.CodContaContabil IS NOT NULL THEN ''U''
                WHEN i.CodContaContabil IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.CodContaContabil, d.CodContaContabil)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d
        ON i.CodContaContabil = d.CodContaContabil AND ISNULL(i.CodCliente,-1) = ISNULL(d.CodCliente,-1);
END
');
EXEC('
CREATE TRIGGER dbo.trg_aud_dim_dre_indicador ON dbo.tb_dim_dre_indicador
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_dim_dre_indicador'',
           CASE WHEN i.SkIndicador IS NOT NULL AND d.SkIndicador IS NOT NULL THEN ''U''
                WHEN i.SkIndicador IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.SkIndicador, d.SkIndicador)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.SkIndicador = d.SkIndicador;
END
');
EXEC('
CREATE TRIGGER dbo.trg_aud_dim_dre_estrutura ON dbo.tb_dim_dre_estrutura
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_dim_dre_estrutura'',
           CASE WHEN i.SkGrupo IS NOT NULL AND d.SkGrupo IS NOT NULL THEN ''U''
                WHEN i.SkGrupo IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.SkGrupo, d.SkGrupo)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.SkGrupo = d.SkGrupo;
END
');
EXEC('
CREATE TRIGGER dbo.trg_aud_dim_marketplace ON dbo.tb_dim_marketplace
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_dim_marketplace'',
           CASE WHEN i.CodMarketplace IS NOT NULL AND d.CodMarketplace IS NOT NULL THEN ''U''
                WHEN i.CodMarketplace IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.CodMarketplace, d.CodMarketplace)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.CodMarketplace = d.CodMarketplace;
END
');
EXEC('
CREATE TRIGGER dbo.trg_aud_dim_origem ON dbo.tb_dim_origem
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_dim_origem'',
           CASE WHEN i.CodOrigem IS NOT NULL AND d.CodOrigem IS NOT NULL THEN ''U''
                WHEN i.CodOrigem IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.CodOrigem, d.CodOrigem)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.CodOrigem = d.CodOrigem;
END
');
EXEC('
CREATE TRIGGER dbo.trg_aud_dim_visao ON dbo.tb_dim_visao
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_dim_visao'',
           CASE WHEN i.CodVisao IS NOT NULL AND d.CodVisao IS NOT NULL THEN ''U''
                WHEN i.CodVisao IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.CodVisao, d.CodVisao)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.CodVisao = d.CodVisao;
END
');
EXEC('
CREATE TRIGGER dbo.trg_aud_cadastro_impostos ON dbo.tb_fin_cadastro_impostos
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_fin_cadastro_impostos'',
           CASE WHEN i.cdi_cd_imposto IS NOT NULL AND d.cdi_cd_imposto IS NOT NULL THEN ''U''
                WHEN i.cdi_cd_imposto IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.cdi_cd_imposto, d.cdi_cd_imposto)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.cdi_cd_imposto = d.cdi_cd_imposto;
END
');
-- Fato: audita somente edicoes manuais da visao Orcado (CodVisao=2)
EXEC('
CREATE TRIGGER dbo.trg_aud_fato_dre_orcado ON dbo.tb_fato_dre
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_fato_dre'',
           CASE WHEN i.IdFato IS NOT NULL AND d.IdFato IS NOT NULL THEN ''U''
                WHEN i.IdFato IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.IdFato, d.IdFato)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.IdFato = d.IdFato
    WHERE ISNULL(i.CodVisao, d.CodVisao) = 2;
END
');
GO

--============================================================================
-- 9. PROC UTILITARIA + BACKFILL INICIAL (visao Realizado) — pares cliente x mes
--============================================================================
EXEC('
CREATE PROCEDURE dbo.sp_fin_dre_carga_all AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @cli int, @a int, @m int;
    DECLARE cur CURSOR FAST_FORWARD FOR
        SELECT DISTINCT c.cli_cd_codigo_cliente, f.Ano, f.Mes
        FROM dbo.tb_fin_prefatura f WITH (NOLOCK)
        JOIN dbo.tb_clientes c WITH (NOLOCK) ON c.cli_id_logistics = f.IdTransportadora
        ORDER BY c.cli_cd_codigo_cliente, f.Ano, f.Mes;
    OPEN cur;
    FETCH NEXT FROM cur INTO @cli, @a, @m;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC dbo.sp_fin_dre_carga @CodCliente = @cli, @Ano = @a, @Mes = @m;
        END TRY
        BEGIN CATCH
            PRINT ''Carga falhou: cliente '' + CAST(@cli AS varchar) + '' '' + CAST(@a AS varchar) + ''/'' + CAST(@m AS varchar) + '' - '' + ERROR_MESSAGE();
        END CATCH
        FETCH NEXT FROM cur INTO @cli, @a, @m;
    END
    CLOSE cur; DEALLOCATE cur;
END
');
GO

EXEC dbo.sp_fin_dre_carga_all;
GO

-- Permissao de execucao para o usuario do relatorio web (se existir no ambiente)
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_relatorio_web')
BEGIN
    GRANT EXECUTE ON dbo.sp_fin_dre_carga     TO usr_relatorio_web;
    GRANT EXECUTE ON dbo.sp_fin_dre_carga_all TO usr_relatorio_web;
END
GO

--============================================================================
-- 10. POS-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fato_dre'))
        THROW 50010, 'tb_fato_dre nao criada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.sp_fin_dre_carga'))
        THROW 50011, 'sp_fin_dre_carga nao criada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_fin_fato_dre'))
        THROW 50012, 'vw_fin_fato_dre nao criada.', 1;
    PRINT 'Migracao concluida.';
    SELECT 'fato_dre_linhas' AS Check_, COUNT(*) AS Valor FROM dbo.tb_fato_dre;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
