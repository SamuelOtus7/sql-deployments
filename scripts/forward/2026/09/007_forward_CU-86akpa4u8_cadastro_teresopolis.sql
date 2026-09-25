/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Cadastro de locais (bairros/distritos) de Teresopolis/RJ na
                 tb_fin_definie_cidade_distrito para o cliente Hawk Transportes
                 (cli_cd_codigo_cliente = 66), bases SRJ5/SRJ6/SRJ7 e contrato
                 'PJ' (ttc_cd_tipo_contrato = 374). Insere primeiro no
                 dicionario tb_fin_distritos_cadastrados os nomes que ainda nao
                 existem (45 novos) e depois os vinculos (78 locais unicos).
                 Fonte: planilha Cidades.xlsx - 80 linhas, deduplicadas
                 (Fazendinha e Quebra Frascos apareciam 2x).
                 Uso: a vw_fin_definie_cidade_distrito e consumida pela proc
                 UspGeraAtualizaCidadesDistanteDiaPacote para resolver a cidade
                 do pacote a partir de geo (bairro/distrito/aldeia/suburbio).
  Rollback     : scripts/rollback/2026/09/007_rollback_CU-86akpa4u8_cadastro_teresopolis.sql
  Objetos      : dbo.tb_fin_distritos_cadastrados (INSERT),
                 dbo.tb_fin_definie_cidade_distrito (INSERT)
  Dependências : dbo.tb_bases, dbo.tb_tipo_contrato, dbo.tb_codigos_cidades,
                 dbo.tb_estados_ibge, dbo.tb_lista, dbo.tb_clientes,
                 dbo.vw_fin_definie_cidade_distrito
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. STAGING: linhas da planilha (base, local, regiao) - 78 unicas
    --==========================================================================
    DECLARE @stage TABLE (
        base_sigla    nvarchar(100) NOT NULL,
        local_nome    varchar(50)   NOT NULL,
        regiao_label  varchar(50)   NOT NULL
    );

    INSERT INTO @stage (base_sigla, local_nome, regiao_label) VALUES
        (N'SRJ5', N'TERESÓPOLIS', N'Distrito'),
        (N'SRJ5', N'Agriões', N'Bairro'),
        (N'SRJ5', N'Albuquerque', N'Bairro'),
        (N'SRJ5', N'Alto', N'Bairro'),
        (N'SRJ5', N'Araras', N'Bairro'),
        (N'SRJ5', N'Bairro dos Artistas', N'Bairro'),
        (N'SRJ5', N'Barra do Imbuí', N'Bairro'),
        (N'SRJ5', N'Barroso', N'Bairro'),
        (N'SRJ5', N'Caleme', N'Bairro'),
        (N'SRJ5', N'Campo Grande', N'Bairro'),
        (N'SRJ5', N'Carlos Guinle', N'Bairro'),
        (N'SRJ5', N'Cascata do Imbuí', N'Bairro'),
        (N'SRJ5', N'Cascata dos Amores', N'Bairro'),
        (N'SRJ5', N'Cascata Guarani', N'Bairro'),
        (N'SRJ5', N'Caxangá', N'Bairro'),
        (N'SRJ5', N'Corta Vento', N'Bairro'),
        (N'SRJ5', N'Ermitage', N'Bairro'),
        (N'SRJ5', N'Espanhol', N'Bairro'),
        (N'SRJ5', N'Fátima', N'Bairro'),
        (N'SRJ5', N'Fazendinha', N'Bairro'),
        (N'SRJ5', N'Fonte Santa', N'Bairro'),
        (N'SRJ5', N'Golfe', N'Bairro'),
        (N'SRJ5', N'Granja Florestal', N'Bairro'),
        (N'SRJ5', N'Iucas', N'Bairro'),
        (N'SRJ5', N'Jardim Cascata', N'Bairro'),
        (N'SRJ5', N'Jardim Europa', N'Bairro'),
        (N'SRJ5', N'Jardim Meudon', N'Bairro'),
        (N'SRJ5', N'Jardim Salaco', N'Bairro'),
        (N'SRJ5', N'Meudon', N'Bairro'),
        (N'SRJ5', N'Morro dos Pinheiros', N'Bairro'),
        (N'SRJ5', N'Nossa Senhora de Fátima', N'Bairro'),
        (N'SRJ5', N'Paineiras', N'Bairro'),
        (N'SRJ5', N'Parque do Imbuí', N'Bairro'),
        (N'SRJ5', N'Parque do Ingá', N'Bairro'),
        (N'SRJ5', N'Parque São Luiz', N'Bairro'),
        (N'SRJ5', N'Pimenteiras', N'Bairro'),
        (N'SRJ5', N'Posse', N'Bairro'),
        (N'SRJ5', N'Prata', N'Bairro'),
        (N'SRJ5', N'Quebra Frascos', N'Bairro'),
        (N'SRJ5', N'Quinta Lebrão', N'Bairro'),
        (N'SRJ5', N'Santa Cecília', N'Bairro'),
        (N'SRJ5', N'São Pedro', N'Bairro'),
        (N'SRJ5', N'Taumaturgo', N'Bairro'),
        (N'SRJ5', N'Tijuca', N'Bairro'),
        (N'SRJ5', N'Vale do Paraíso', N'Bairro'),
        (N'SRJ5', N'Várzea', N'Bairro'),
        (N'SRJ5', N'Vila Muqui', N'Bairro'),
        (N'SRJ5', N'VALE DE BONSUCESSO', N'Distrito'),
        (N'SRJ5', N'Campanha', N'Bairro'),
        (N'SRJ5', N'Corrêgo Sujo', N'Bairro'),
        (N'SRJ5', N'Vargem Grande', N'Bairro'),
        (N'SRJ5', N'Venda Nova', N'Bairro'),
        (N'SRJ5', N'Vista Alegre', N'Bairro'),
        (N'SRJ5', N'Frades', N'Bairro'),
        (N'SRJ5', N'Bonsucesso', N'Bairro'),
        (N'SRJ5', N'Motas', N'Bairro'),
        (N'SRJ5', N'Sebastiana', N'Bairro'),
        (N'SRJ5', N'Santa Rosa', N'Bairro'),
        (N'SRJ5', N'Vieira', N'Bairro'),
        (N'SRJ5', N'Morro Agudo', N'Bairro'),
        (N'SRJ5', N'Boa Vista', N'Bairro'),
        (N'SRJ5', N'VALE DO PARQUEQUER', N'Distrito'),
        (N'SRJ6', N'Três Córregos', N'Bairro'),
        (N'SRJ7', N'Pessegueiros', N'Bairro'),
        (N'SRJ5', N'Santa Rita', N'Bairro'),
        (N'SRJ5', N'Campo Limpo', N'Bairro'),
        (N'SRJ5', N'Colonia Alpina', N'Bairro'),
        (N'SRJ5', N'Granja Mafra', N'Bairro'),
        (N'SRJ5', N'Cruzeiro', N'Bairro'),
        (N'SRJ5', N'Andradas', N'Bairro'),
        (N'SRJ5', N'Providência', N'Bairro'),
        (N'SRJ5', N'Ponte Nova', N'Bairro'),
        (N'SRJ5', N'Quebra Coco', N'Bairro'),
        (N'SRJ5', N'Água Quente', N'Bairro'),
        (N'SRJ5', N'Volta do Pião', N'Bairro'),
        (N'SRJ5', N'Serra do Capim', N'Bairro'),
        (N'SRJ5', N'Prates', N'Bairro'),
        (N'SRJ5', N'Retiro da Serra', N'Bairro');

    --==========================================================================
    -- 2. PRE-CHECKS: resolver chaves de lookup
    --==========================================================================
    DECLARE @cd_cliente  int = 66;   -- Hawk Transportes
    DECLARE @cd_estado   int;
    DECLARE @cd_cidade   int;
    DECLARE @cd_contrato int;

    SELECT @cd_estado = id
    FROM dbo.tb_estados_ibge
    WHERE sigla = 'RJ';

    SELECT @cd_cidade = cid_cd_cidade
    FROM dbo.tb_codigos_cidades
    WHERE cid_ds_cidade = N'Teresópolis'
      AND cid_cd_estado = 33; -- IBGE RJ

    SELECT @cd_contrato = ttc_cd_tipo_contrato
    FROM dbo.tb_tipo_contrato
    WHERE ttc_cd_cliente = @cd_cliente
      AND ttc_nm_tipo = 'PJ'
      AND ttc_in_ativo = 1
      AND ttc_in_excluido = 0;

    IF @cd_cliente IS NULL
       OR NOT EXISTS (SELECT 1 FROM dbo.tb_clientes
                      WHERE cli_cd_codigo_cliente = @cd_cliente
                        AND cli_in_excluido = 0)
        THROW 50001, 'Cliente 66 (Hawk Transportes) nao encontrado.', 1;

    IF @cd_estado IS NULL
        THROW 50002, 'Estado RJ nao encontrado em tb_estados_ibge.', 1;

    IF @cd_cidade IS NULL
        THROW 50003, 'Cidade Teresopolis (RJ) nao encontrada em tb_codigos_cidades.', 1;

    IF @cd_contrato IS NULL
        THROW 50004, 'Contrato PJ do cliente 66 nao encontrado em tb_tipo_contrato.', 1;

    -- toda base da staging precisa existir para o cliente 66 (1:1 por sigla)
    IF EXISTS (
        SELECT 1
        FROM @stage s
        LEFT JOIN dbo.tb_bases b
            ON b.bss_ds_sigla = s.base_sigla
           AND b.bss_cod_cliente = @cd_cliente
           AND b.bss_in_excluido = 0
        GROUP BY s.base_sigla
        HAVING COUNT(DISTINCT b.bss_cd_base) <> 1
    )
        THROW 50005, 'Base da staging nao encontrada ou ambigua para o cliente 66.', 1;

    -- toda regiao da staging precisa existir na lista 'Regiao de entrega'
    IF EXISTS (
        SELECT 1
        FROM @stage s
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.tb_lista l
            WHERE l.lst_nm_lista = 'Regiao de entrega'
              AND l.lst_ds_label = s.regiao_label
        )
    )
        THROW 50006, 'Regiao da staging nao encontrada em tb_lista.', 1;

    --==========================================================================
    -- 3. INSERT dicionario de distritos (somente nomes novos - idempotente)
    --==========================================================================
    INSERT INTO dbo.tb_fin_distritos_cadastrados (NomeDistrito)
    SELECT DISTINCT s.local_nome
    FROM @stage s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.tb_fin_distritos_cadastrados d
        WHERE d.NomeDistrito = s.local_nome
    );

    DECLARE @distritos_inseridos int = @@ROWCOUNT;

    --==========================================================================
    -- 4. INSERT vinculos cidade x distrito (idempotente)
    --==========================================================================
    INSERT INTO dbo.tb_fin_definie_cidade_distrito (
        fcd_cd_Base, fcd_cd_contrato, fcd_cd_cidade, fcd_cd_distrito,
        fcd_cd_estado, fcd_cd_cliente, fcd_cd_regiao, fcd_in_excluido
    )
    SELECT
        b.bss_cd_base, @cd_contrato, @cd_cidade, d.IdDistrito,
        @cd_estado, @cd_cliente, l.lst_cd_lista, 0
    FROM @stage s
    JOIN dbo.tb_bases b
        ON b.bss_ds_sigla = s.base_sigla
       AND b.bss_cod_cliente = @cd_cliente
       AND b.bss_in_excluido = 0
    JOIN dbo.tb_fin_distritos_cadastrados d
        ON d.NomeDistrito = s.local_nome
    JOIN dbo.tb_lista l
        ON l.lst_nm_lista = 'Regiao de entrega'
       AND l.lst_ds_label = s.regiao_label
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_definie_cidade_distrito f
        WHERE f.fcd_cd_cliente  = @cd_cliente
          AND f.fcd_cd_Base     = b.bss_cd_base
          AND f.fcd_cd_contrato = @cd_contrato
          AND f.fcd_cd_cidade   = @cd_cidade
          AND f.fcd_cd_distrito = d.IdDistrito
          AND f.fcd_cd_regiao   = l.lst_cd_lista
    );

    DECLARE @vinculos_inseridos int = @@ROWCOUNT;

    --==========================================================================
    -- 5. POS-CHECKS
    --==========================================================================
    DECLARE @total_vinculos int;
    SELECT @total_vinculos = COUNT(DISTINCT f.fcd_cod)
    FROM @stage s
    JOIN dbo.tb_bases b
        ON b.bss_ds_sigla = s.base_sigla
       AND b.bss_cod_cliente = @cd_cliente
       AND b.bss_in_excluido = 0
    JOIN dbo.tb_fin_distritos_cadastrados d
        ON d.NomeDistrito = s.local_nome
    JOIN dbo.tb_lista l
        ON l.lst_nm_lista = 'Regiao de entrega'
       AND l.lst_ds_label = s.regiao_label
    JOIN dbo.tb_fin_definie_cidade_distrito f
        ON f.fcd_cd_cliente  = @cd_cliente
       AND f.fcd_cd_Base     = b.bss_cd_base
       AND f.fcd_cd_contrato = @cd_contrato
       AND f.fcd_cd_cidade   = @cd_cidade
       AND f.fcd_cd_distrito = d.IdDistrito
       AND f.fcd_cd_regiao   = l.lst_cd_lista;

    IF @total_vinculos <> 78
        THROW 50007, 'Pos-check falhou: esperado 78 vinculos cadastrados.', 1;

    PRINT 'Distritos inseridos em tb_fin_distritos_cadastrados: ' + CAST(@distritos_inseridos AS varchar);
    PRINT 'Vinculos inseridos em tb_fin_definie_cidade_distrito: ' + CAST(@vinculos_inseridos AS varchar);
    PRINT 'Total de vinculos da staging presentes: ' + CAST(@total_vinculos AS varchar);

    COMMIT TRAN;
    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
