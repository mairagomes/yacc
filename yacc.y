%{
void yyerror(const char *s);
int yylex(void);
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


typedef enum { 
    TIPO_INTEIRO, 
    TIPO_STRING 
} Valor;

typedef struct Var {
    char *tipo;
    char *id;
    Valor tipo_valor;
    union {
        int numero_inteiro;
        char *cadeia_valor;
    } valor;
    char *tipo_linha;
    struct Var *p;
} Var;

typedef struct Pilha {
    Var *topo;
    struct Pilha *p;
} Pilha;

Pilha *stack = NULL;

void inicia_pilha() {
    stack = NULL;
}

char* buscar_tipo_linha_variavel(char *nome_variavel) {
    Pilha *bloco_a = stack;
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        
        for (; temp != NULL; temp = temp->p) {
            if (strcmp(temp->id, nome_variavel) == 0) {
                return temp->tipo_linha; // Retorna o tipo de statement da variável se encontrada
            }
        }
        bloco_a = bloco_a->p;
    }   
    return NULL; // Retorna NULL se a variável não for encontrada
}

char* apaga_esp(const char* str) {
    int len = strlen(str);
    char* string_atualiazada = malloc(len + 1); // Aloca memória para a nova string

    if (string_atualiazada == NULL) {
        return NULL; // Retorna NULL em caso de falha na alocação de memória
    }

    int j = 0;
    for (int i = 0; i < len; i++) {
        if (str[i] != ' ' && str[i] != '\t') {
            string_atualiazada[j++] = str[i];
        }
    }
    string_atualiazada[j] = '\0'; // Termina a nova string

    return string_atualiazada;
}

void empilha() {
    Pilha *adiciona_bloco = malloc(sizeof(Pilha));
    if (adiciona_bloco == NULL) {
        // Tratamento de erro, se a alocação falhar
        return;
    }
    
    adiciona_bloco->topo = NULL;
    adiciona_bloco->p = stack;
    stack = adiciona_bloco;
}

void desempilha() {
    if (stack != NULL) {
        stack = stack->p;
    }

}

Var* variavel_pilha(char *identificador) {
    Pilha *bloco_a = stack;
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        while (temp != NULL) {
            if (strcmp(temp->id, identificador) == 0) {
                return temp;
            }
            temp = temp->p;
        }
        bloco_a = bloco_a->p;
    }
    return NULL;
}

Var* variavel_bloco(char *identificador) {
    if (stack == NULL) {
        return NULL;
    }

    Var *temp = stack->topo;
    while (temp != NULL) {
        if (strcmp(temp->id, identificador) == 0) {
            return temp;
        }
        temp = temp->p;
    }
    return NULL;
}

char* verifica_tipo_variavel(char *nome_var) {
    Pilha *bloco_a = stack;
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        for (; temp != NULL; temp = temp->p) {
            if (strcmp(temp->id, nome_var) == 0) {
                return temp->tipo; 
            }
        }
        bloco_a = bloco_a->p;
    }

    printf("Erro: variável %s não encontrada\n", nome_var);
    return NULL;
}

int menor_var(char *nome_var) {
    Pilha *bloco_a = stack;
    
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        
        while (temp != NULL && strcmp(temp->id, nome_var) != 0) {
            temp = temp->p;
        }
        
        if (temp != NULL) {
            if (temp->tipo_valor == TIPO_INTEIRO) {
                return temp->valor.numero_inteiro; // Retorna o valor inteiro se for do tipo NUMERO
            } else {
                return 0; // Tratar erro de variável não do tipo NUMERO
            }
        }
        
        bloco_a = bloco_a->p;
    }
    
    // Se chegou aqui, a variável não foi encontrada em nenhum bloco
    printf("Erro: variável %s não encontrada\n", nome_var);
    return 0; // Valor padrão se a variável não for encontrada
}

char* variavel_str(char *nome_var) {
    Pilha *bloco_a = stack;
    
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        
        while (temp != NULL && strcmp(temp->id, nome_var) != 0) {
            temp = temp->p;
        }
        
        if (temp != NULL) {
            if (temp->tipo_valor == TIPO_STRING) {
                return temp->valor.cadeia_valor; // Retorna a cadeia de caracteres
            } else {
                return NULL; // Trata o erro aqui ou retorna um valor padrão
            }
        }
        
        bloco_a = bloco_a->p;
    }
    
    printf("Erro: variável %s não encontrada\n", nome_var);
    return NULL; // Valor padrão se a variável não for encontrada
}



char* apaga_espa_aspas(const char* str) {
    int len = strlen(str);
    char* string_atualiazada = (char*)malloc(len + 1); // Aloca memória para a nova string

    if (string_atualiazada == NULL) {
        exit(1); // Sai se a alocação falhar
    }

    int j = 0;
    int aspas = 0; // Flag para rastrear se estamos dentro de aspas

    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] == '"') {
            aspas = 1 - aspas; // Alterna o estado dentro/fora de aspas
        }

        if (aspas || (str[i] != ' ' && str[i] != '\t')) {
            string_atualiazada[j] = str[i];
            j++;
        }
    }
    string_atualiazada[j] = '\0'; // Termina a nova string

    return string_atualiazada;
}

void var_numero(char *tipo, char *id, int numero_inteiro, char *tipo_linha) {
    if (stack == NULL) {
        return;
    }
    Var *atualiza_valor = (Var *)malloc(sizeof(Var));
    atualiza_valor->tipo = strdup(tipo);
    atualiza_valor->id = strdup(id);
    atualiza_valor->tipo_valor = TIPO_INTEIRO;
    atualiza_valor->valor.numero_inteiro = numero_inteiro;

    atualiza_valor->tipo_linha = tipo_linha;

    atualiza_valor->p = stack->topo;
    stack->topo = atualiza_valor;
}

void var_cadeia(char *tipo, char *id, char *cadeia_valor, char *tipo_linha) {
    if (stack == NULL) return;

    Var *atualiza_valor = (Var *)malloc(sizeof(Var));
    if (atualiza_valor == NULL) return;
    atualiza_valor->tipo = strdup(tipo);
    atualiza_valor->id = strdup(id);
    atualiza_valor->tipo_valor = TIPO_STRING;
    atualiza_valor->valor.cadeia_valor = strdup(cadeia_valor);
    atualiza_valor->tipo_linha = strdup(tipo_linha);
    atualiza_valor->tipo_linha = tipo_linha;

    atualiza_valor->p = stack->topo;
    stack->topo = atualiza_valor;
}

void atualiza_variavel(char *tipo, char *id, int numero_inteiro, char *cadeia_valor, char *tipo_linha) {
    Pilha *bloco_a = stack;
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        while (temp != NULL) {
            if (strcmp(temp->id, id) == 0) {
                if (strcmp(tipo, "NUMERO") == 0) {
                    temp->tipo_valor = TIPO_INTEIRO;
                    temp->valor.numero_inteiro = numero_inteiro;
                } else if (strcmp(tipo, "CADEIA") == 0) {
                    temp->tipo_valor = TIPO_STRING;
                    if (strcmp(temp->tipo, "CADEIA") == 0) {
                        free(temp->valor.cadeia_valor);
                    }
                    temp->valor.cadeia_valor = strdup(cadeia_valor);
                }
                free(temp->tipo);
                temp->tipo = strdup(tipo);

                temp->tipo_linha = strdup(tipo_linha);
                return;
            }
            temp = temp->p;
        }
        bloco_a = bloco_a->p;
    }
    printf("Erro: variável %s não encontrada.\n", id);
}

void imprimir_pilha() {
    Pilha *bloco_a = stack;
    while (bloco_a != NULL) {
        Var *temp = bloco_a->topo;
        while (temp != NULL) {
            if (temp->tipo_valor == TIPO_INTEIRO) {
                printf("%d\n", temp->valor.numero_inteiro);
            } else if (temp->tipo_valor == TIPO_STRING) {
                printf("\"%s\"\n", temp->valor.cadeia_valor);
            } else {
                // Aqui você pode tratar outros tipos de dados ou mensagens de erro
                if (strcmp(temp->tipo, "ERRO") == 0) {
                    printf("Erro: %s\n", temp->id); // Supondo que 'id' armazene a mensagem de erro
                } else {
                    printf("Erro: tipos não compatíveis\n");
                }
            }
            temp = temp->p;
        }
        bloco_a = bloco_a->p;
    }
}


char* num_em_str(int numero) {
    char *buffer = (char *)malloc(50 * sizeof(char));
    if (buffer != NULL) {
        sprintf(buffer, "%d", numero);
    }
    return buffer;
}

// Função para verificar se uma string é um número
int e_numero(const char *str) {
    // Verifica se a string está vazia
    if (*str == '\0') {
        return 0;
    }
    // Verifica sinal de número positivo ou negativo
    if (*str == '+' || *str == '-') {
        str++;
    }
    int e_digito = 0;
    int has_dot = 0;

    // Verifica cada caractere da string
    while (*str) {
        if (isdigit(*str)) {
            e_digito = 1;
        } else if (*str == '.') {
            if (has_dot) {
                return 0; // Mais de um ponto decimal
            }
            has_dot = 1;
        } else {
            return 0; // Caractere não é um dígito nem ponto decimal
        }
        str++;
    }

    // Verifica se a string tinha pelo menos um dígito
    return e_digito;
}

// Função para verificar se uma string é uma cadeia de caracteres
int e_string(const char *str) {
    // Verifica se a string começa e termina com aspas
    size_t len = strlen(str);
    return len >= 2 && str[0] == '"' && str[len - 1] == '"';
}

// Função para verificar o tipo da string
char* verificar_tipo(const char *str) {
    if (e_numero(str)) {
        return "NUMERO";
    } else if (e_string(str)) {
        return "CADEIA";
    }
}

char* retira_ultimo_digito(char *str) {
    size_t len = strlen(str); // Obter o comprimento da string

    if (len == 0) {
        return NULL; // Retornar NULL se a string estiver vazia
    }

    // Alocar memória para a nova string, excluindo o último caractere (a aspas de fechamento)
    char *string_atualiazada = (char *)malloc(len * sizeof(char));
    if (string_atualiazada == NULL) {
        return NULL;
    }

    // Copiar a string original para a nova string, excluindo o último caractere
    strncpy(string_atualiazada, str, len - 1);
    string_atualiazada[len - 1] = '\0'; // Adicionar o caractere nulo terminador

    return string_atualiazada;
}

char* retira_primeiro_digito(char *str) {
    size_t len = strlen(str); // Obter o comprimento da string

    if (len <= 1) {
        return NULL; // Retornar NULL se a string estiver vazia ou tiver apenas um caractere
    }

    // Alocar memória para a nova string, excluindo o primeiro caractere (a aspas de abertura)
    char *string_atualiazada = (char *)malloc(len * sizeof(char));
    if (string_atualiazada == NULL) {
        return NULL;
    }

    // Copiar a string original para a nova string, excluindo o primeiro caractere
    strcpy(string_atualiazada, str + 1);

    return string_atualiazada;
}



%}

%union 
{
	int number;
    char *string;
}

%token BLOCO_INICIO BLOCO_FIM IDENTIFICADOR CADEIA
%token NUMERO
%token TIPO_INTEIRO TIPO_STRING PRINT

%%

program:
    program statement {
    }
    | 
    ;

statement:
    statement_inicio
    | fim_bloco
    | declaration ';'
    | assignment ';'
    | print_statement ';'
    | 
    ;

statement_inicio:
    BLOCO_INICIO {
        empilha();
    }
    ;

fim_bloco:
    BLOCO_FIM {
        desempilha();
    }
    ;

declaration:
    TIPO_STRING declaration_list_str
    | TIPO_INTEIRO declaration_list_num
    ;

declaration_list_str:
    declaration_str
    | declaration_list_str ',' declaration_str
    ;
declaration_str:
    IDENTIFICADOR '=' expr_str { 
        char* var_um = apaga_esp($1.string);

        // Verifica se a variável já existe na pilha
        if (variavel_pilha(var_um) == NULL) {
            var_cadeia("CADEIA", var_um, $3.string, "declaration");
        } 
        // Caso contrário, verifica se a variável já existe no bloco
        else if (variavel_bloco(var_um) == NULL) {
            var_cadeia("CADEIA", var_um, $3.string, "declaration");
        } 
        // Se a variável já existe, verifica o tipo de declaração
        else if (strcmp(buscar_tipo_linha_variavel(var_um), "assignment") == 0) {
            atualiza_variavel("CADEIA", var_um, 0, $3.string, "declaration");
        } 
        // Caso contrário, lança um erro de variável já declarada
        else {
            printf(" Erro: variável '%s' já declarada no Pilha\n", var_um);
        }
    }
    | IDENTIFICADOR {
        char* var_um = apaga_esp($1.string);

        // Verifica se a variável já existe na pilha
        if (variavel_pilha(var_um) == NULL) {
            var_cadeia("CADEIA", var_um, "", "declaration");
        } 
        // Caso contrário, verifica se a variável já existe no bloco
        else if (variavel_bloco(var_um) == NULL) {
            var_cadeia("CADEIA", var_um, "", "declaration");
        } 
        // Se a variável já existe, verifica o tipo de declaração
        else if (strcmp(buscar_tipo_linha_variavel(var_um), "assignment") == 0) {
            atualiza_variavel("CADEIA", var_um, 0, "", "declaration");
        } 
        // Caso contrário, lança um erro de variável já declarada
        else {
            printf(" Erro: variável '%s' já declarada no Pilha\n", var_um);
        }
    }
    ;
expr_str:
    CADEIA { 
        char* var_um = apaga_espa_aspas($1.string);
        $$.string = var_um;
    }
    | IDENTIFICADOR { 
        char* var_um = apaga_esp($1.string);
        if(variavel_pilha(var_um) != NULL){
            if(strcmp(verifica_tipo_variavel(var_um), "CADEIA") == 0){
                $$.string = variavel_str(var_um); 
            }
            else{
                printf(" Erro: tipos não compatíveis\n");
            }
        }
    }
    | expr_str '+' CADEIA {
        char* var_um = retira_ultimo_digito($1.string);
        char* var_tres = apaga_espa_aspas($3.string);
        var_tres = retira_primeiro_digito(var_tres);
        size_t len1 = strlen(var_um);
        size_t len2 = strlen(var_tres);
        char* result = (char*)malloc(len1 + len2 + 1);

        strcpy(result, var_um);
        strcat(result, var_tres);

        $$.string  = result;
    }
    | expr_str '+' IDENTIFICADOR {
        char* var_tres = apaga_esp($3.string);
        if(variavel_pilha(var_tres) != NULL){
            if(strcmp(verifica_tipo_variavel(var_tres), "CADEIA") == 0){
                char* var_um = retira_ultimo_digito($1.string);
                char* valor_variavel_s3 = variavel_str(var_tres);
                valor_variavel_s3 = retira_primeiro_digito(valor_variavel_s3);

                size_t len1 = strlen(var_um);
                size_t len2 = strlen(valor_variavel_s3);
                char* result = (char*)malloc(len1 + len2 + 1);

                strcpy(result, var_um);
                strcat(result, valor_variavel_s3);

                $$.string  = result;
            }
            else{
                printf(" Erro: tipos não compatíveis\n");
            }
        }
        else{
            printf(" Erro: variável não declarada\n");
        }
    }
    ;
declaration_list_num:
    declaracao_numero
    | declaration_list_num ',' declaracao_numero
    ;
declaracao_numero:
    IDENTIFICADOR '=' expressao_numero { 
        char* var_um = apaga_esp($1.string);
        if (variavel_pilha(var_um) == NULL) {
            var_numero("NUMERO", var_um, $3.number, "declaration");
        }
        else {
            if (variavel_bloco(var_um) == NULL){
                var_numero("NUMERO", var_um, $3.number, "declaration");
            }
            else {
                if(strcmp(buscar_tipo_linha_variavel(var_um), "assignment") == 0){
                    atualiza_variavel("NUMERO", var_um, $3.number, "", "declaration");
                }
                else{
                    printf(" Erro: variável '%s' já declarada no Pilha\n", var_um);
                }
            }
        }
    }
    | IDENTIFICADOR {
        char* var_um = apaga_esp($1.string); 
        if (variavel_pilha(apaga_esp(var_um)) == NULL) {
            var_numero("NUMERO", var_um, 0, "declaration");
        }
        else {
            if (variavel_bloco(var_um) == NULL){
                var_numero("NUMERO", var_um, 0, "declaration");
            }
            else {
                if(strcmp(buscar_tipo_linha_variavel(var_um), "assignment") == 0){
                    atualiza_variavel("NUMERO", var_um, 0, "", "declaration");
                }
                else{
                    printf(" Erro: variável '%s' já declarada no Pilha\n", var_um);
                }
            }
        }
    }
    ;
expressao_numero:
    NUMERO { 
        $$.number = $1.number; 
    }
    | IDENTIFICADOR { 
        char* var_um = apaga_esp($1.string);
        if(variavel_pilha(var_um) != NULL){
            if(strcmp(verifica_tipo_variavel(var_um), "NUMERO") == 0){
                $$.number = menor_var(var_um); 
            }
            else{
                printf(" Erro: tipos não compatíveis\n");
            }
        }
    }
    | expressao_numero '+' NUMERO { 
        $$.number  = $1.number + $3.number; 
    }
    | expressao_numero '+' IDENTIFICADOR {
        char* var_tres = apaga_esp($3.string);
        if(variavel_pilha(var_tres) != NULL){
            if(strcmp(verifica_tipo_variavel(var_tres), "NUMERO") == 0){
                int valor_variavel_s3 = menor_var(var_tres);
                $$.number  = $1.number + valor_variavel_s3; 
            }
            else{
                //char* valor_variavel_s3 = menor_var(var_tres);
                //$$.string  = $1.number + valor_variavel_s3; 
                printf(" Erro: tipos não compatíveis\n");
            }
        }
        else{
            printf(" Erro: variável não declarada\n");
        }
    }
    ;

assignment:
    IDENTIFICADOR '=' expr {
        char* tipo_expressao = verificar_tipo($3.string);
        char* var_um = apaga_esp($1.string);
        if (variavel_pilha(var_um) != NULL) {
            char* tipo_variavel = verifica_tipo_variavel(var_um);
            tipo_expressao = verificar_tipo($3.string);
            if (strcmp(tipo_variavel, tipo_expressao) == 0) {
                if (variavel_bloco(var_um) == NULL){
                    if (strcmp(tipo_expressao, "NUMERO") == 0){
                        int expressao_number = atoi($3.string);
                        var_numero("NUMERO", var_um, expressao_number, "assignment");
                    }
                    else if (strcmp(tipo_expressao, "CADEIA") == 0){
                        var_cadeia("CADEIA", var_um, $3.string, "assignment");
                    }
                }
                else {
                    if (strcmp(tipo_expressao, "NUMERO") == 0){
                        int expressao_number = atoi($3.string);
                        atualiza_variavel("NUMERO", var_um, expressao_number, "", "declaration");
                    }
                    else if (strcmp(tipo_expressao, "CADEIA") == 0){
                        char* nova_cadeia;
                        nova_cadeia = (char *)malloc((strlen($3.string) + 1) * sizeof(char));
                        strcpy(nova_cadeia, $3.string);
                        atualiza_variavel("CADEIA", var_um, 0, nova_cadeia, "declaration");
                        free(nova_cadeia);
                    }
                    else{
                        printf(" Erro: tipo inválido\n");
                    }
                }
            }
            else {
                printf(" Erro: tipos não compatíveis\n");
            }
        } else {
            printf(" Erro: variável '%s' não declarada\n", var_um);
        }
    }
expr:
    NUMERO {
        $$.string = num_em_str($1.number);
    }
    | CADEIA {
        char* var_um = apaga_espa_aspas($1.string);
        $$.string = var_um;
    }
    | IDENTIFICADOR {
        char* var_um = apaga_esp($1.string);
        if (variavel_pilha(var_um) != NULL) {
            char* tipo_variavel = verifica_tipo_variavel(var_um);
            if(strcmp(tipo_variavel, "NUMERO") == 0){
                int valor_variavel_s1 = menor_var(var_um);
                $$.string = num_em_str(valor_variavel_s1);
            }
            else if(strcmp(tipo_variavel, "CADEIA") == 0){
                char* valor_variavel_s1 = variavel_str(var_um);
                $$.string = valor_variavel_s1;
            }
            else {
                printf(" Erro: variável '%s' com tipo inválido\n", var_um);
            }
        } 
        else {
            printf(" Erro: variável '%s' não declarada\n", var_um);
        }
    }
    | expr '+' NUMERO {
        char* tipo_expressao = verificar_tipo($1.string);
        if (strcmp(tipo_expressao, "NUMERO") == 0 ) {
            int soma = atoi($1.string) + $3.number;
            $$.string = num_em_str(soma);
        } else {
           printf("Erro: Tipos incompatíveis\n");
        }
    }
    | expr '+' CADEIA {
        char* tipo_expressao = verificar_tipo($1.string);
        if (strcmp(tipo_expressao, "CADEIA") == 0) {
            char* var_um = retira_ultimo_digito($1.string);
            char* var_tres = apaga_espa_aspas($3.string);
            var_tres = retira_primeiro_digito(var_tres);

            size_t len1 = strlen(var_um);
            size_t len2 = strlen(var_tres);
            char* result = (char*)malloc(len1 + len2 + 1);

            strcpy(result, var_um);
            strcat(result, var_tres);

            $$.string  = result;
        } 
        else {
           printf(" Erro: Tipos incompatíveis\n");
        }
    }
    | expr '+' IDENTIFICADOR {
        char* tipo_expressao = verificar_tipo($1.string);
        char* var_tres = apaga_esp($3.string);
        if (variavel_pilha(var_tres) != NULL) {
            char* tipo_variavel = verifica_tipo_variavel(var_tres);
            if (strcmp(tipo_expressao, tipo_variavel) == 0){
                if (strcmp(tipo_expressao, "NUMERO") == 0) {
                    int valor_variavel_s3 = menor_var(var_tres);
                    int soma = atoi($1.string) + valor_variavel_s3;
                    $$.string = num_em_str(soma);
                }
                else if (strcmp(tipo_expressao, "CADEIA") == 0){
                    char* var_um = retira_ultimo_digito($1.string);
                    char* valor_variavel_s3 = variavel_str(var_tres);
                    valor_variavel_s3 = retira_primeiro_digito(valor_variavel_s3);

                    size_t len1 = strlen(var_um);
                    size_t len2 = strlen(valor_variavel_s3);
                    char* result = (char*)malloc(len1 + len2 + 1);

                    strcpy(result, var_um);
                    strcat(result, valor_variavel_s3);

                    $$.string  = result;
                }
            }
            else {
                printf(" Erro: tipos não compatíveis\n");
            }
        }
        else {
            printf("Erro: variável '%s' não declarada\n", var_tres);
        }

    }

print_statement:
    PRINT IDENTIFICADOR  { 
        char* var_dois = apaga_esp($2.string);

        if(variavel_pilha(var_dois) != NULL){
            if(strcmp(verifica_tipo_variavel(var_dois), "NUMERO") == 0){
                printf(" %d\n", menor_var(var_dois));
            }
            else{
                printf(" %s\n", variavel_str(var_dois));
            }
        }
        else {
            printf(" Erro: variável não declarada\n");
        }
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    inicia_pilha();
    return yyparse();
}