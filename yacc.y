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

void empilha() {
    Pilha *novo_bloco = malloc(sizeof(Pilha));
    if (!novo_bloco) return;
    novo_bloco->topo = NULL;
    novo_bloco->p = stack;
    stack = novo_bloco;
}

void desempilha() {
    if (stack) {
        Pilha *bloco_antigo = stack;
        stack = stack->p;
        free(bloco_antigo);
    }
}

char* buscar_tipo_linha_variavel(char *nome_variavel) {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (strcmp(temp->id, nome_variavel) == 0) {
                return temp->tipo_linha;
            }
        }
    }
    return NULL;
}

char* verifica_tipo_variavel(char *nome_var) {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (strcmp(temp->id, nome_var) == 0) {
                return temp->tipo;
            }
        }
    }
    printf("Erro: variável %s não encontrada\n", nome_var);
    return NULL;
}

int menor_var(char *nome_var) {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (strcmp(temp->id, nome_var) == 0) {
                return (temp->tipo_valor == TIPO_INTEIRO) ? temp->valor.numero_inteiro : 0;
            }
        }
    }
    printf("Erro: variável %s não encontrada\n", nome_var);
    return 0;
}

char* variavel_str(char *nome_var) {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (strcmp(temp->id, nome_var) == 0) {
                return (temp->tipo_valor == TIPO_STRING) ? temp->valor.cadeia_valor : NULL;
            }
        }
    }
    printf("Erro: variável %s não encontrada\n", nome_var);
    return NULL;
}

char* apaga_esp(const char* str) {
    int len = strlen(str);
    char* string_atualiazada = malloc(len + 1);
    if (!string_atualiazada) return NULL;

    int j = 0;
    for (int i = 0; i < len; i++) {
        if (str[i] != ' ' && str[i] != '\t') {
            string_atualiazada[j++] = str[i];
        }
    }
    string_atualiazada[j] = '\0';
    return string_atualiazada;
}

char* apaga_espa_aspas(const char* str) {
    int len = strlen(str);
    char* string_atualiazada = malloc(len + 1);
    if (!string_atualiazada) exit(1);

    int j = 0, aspas = 0;
    for (int i = 0; str[i]; i++) {
        if (str[i] == '"') {
            aspas = 1 - aspas;
        }
        if (aspas || (str[i] != ' ' && str[i] != '\t')) {
            string_atualiazada[j++] = str[i];
        }
    }
    string_atualiazada[j] = '\0';
    return string_atualiazada;
}

char* retira_ultimo_digito(char *str) {
    size_t len = strlen(str);
    if (len == 0) return NULL;
    char *string_atualiazada = malloc(len);
    if (!string_atualiazada) return NULL;
    strncpy(string_atualiazada, str, len - 1);
    string_atualiazada[len - 1] = '\0';
    return string_atualiazada;
}

char* retira_primeiro_digito(char *str) {
    size_t len = strlen(str);
    if (len <= 1) return NULL;
    char *string_atualiazada = malloc(len);
    if (!string_atualiazada) return NULL;
    strcpy(string_atualiazada, str + 1);
    return string_atualiazada;
}

void var_numero(char *tipo, char *id, int numero_inteiro, char *tipo_linha) {
    if (!stack) return;
    Var *novo_var = malloc(sizeof(Var));
    if (!novo_var) return;
    novo_var->tipo = strdup(tipo);
    novo_var->id = strdup(id);
    novo_var->tipo_valor = TIPO_INTEIRO;
    novo_var->valor.numero_inteiro = numero_inteiro;
    novo_var->tipo_linha = strdup(tipo_linha);
    novo_var->p = stack->topo;
    stack->topo = novo_var;
}

void var_cadeia(char *tipo, char *id, char *cadeia_valor, char *tipo_linha) {
    if (!stack) return;
    Var *novo_var = malloc(sizeof(Var));
    if (!novo_var) return;
    novo_var->tipo = strdup(tipo);
    novo_var->id = strdup(id);
    novo_var->tipo_valor = TIPO_STRING;
    novo_var->valor.cadeia_valor = strdup(cadeia_valor);
    novo_var->tipo_linha = strdup(tipo_linha);
    novo_var->p = stack->topo;
    stack->topo = novo_var;
}

void atualiza_variavel(char *tipo, char *id, int numero_inteiro, char *cadeia_valor, char *tipo_linha) {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (strcmp(temp->id, id) == 0) {
                free(temp->tipo);
                temp->tipo = strdup(tipo);
                temp->tipo_linha = strdup(tipo_linha);
                if (strcmp(tipo, "NUMERO") == 0) {
                    temp->tipo_valor = TIPO_INTEIRO;
                    temp->valor.numero_inteiro = numero_inteiro;
                } else if (strcmp(tipo, "CADEIA") == 0) {
                    if (temp->tipo_valor == TIPO_STRING) {
                        free(temp->valor.cadeia_valor);
                    }
                    temp->tipo_valor = TIPO_STRING;
                    temp->valor.cadeia_valor = strdup(cadeia_valor);
                }
                return;
            }
        }
    }
    printf("Erro: variável %s não encontrada.\n", id);
}

Var* variavel_pilha(char *identificador) {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (strcmp(temp->id, identificador) == 0) {
                return temp;
            }
        }
    }
    return NULL;
}

Var* variavel_bloco(char *identificador) {
    if (!stack) return NULL;
    for (Var *temp = stack->topo; temp; temp = temp->p) {
        if (strcmp(temp->id, identificador) == 0) {
            return temp;
        }
    }
    return NULL;
}

void imprimir_pilha() {
    for (Pilha *bloco_a = stack; bloco_a; bloco_a = bloco_a->p) {
        for (Var *temp = bloco_a->topo; temp; temp = temp->p) {
            if (temp->tipo_valor == TIPO_INTEIRO) {
                printf("%d\n", temp->valor.numero_inteiro);
            } else if (temp->tipo_valor == TIPO_STRING) {
                printf("\"%s\"\n", temp->valor.cadeia_valor);
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        }
    }
}

char* num_em_str(int numero) {
    char *buffer = malloc(50 * sizeof(char));
    if (buffer) {
        sprintf(buffer, "%d", numero);
    }
    return buffer;
}

int e_numero(const char *str) {
    if (*str == '\0') return 0;
    if (*str == '+' || *str == '-') str++;
    int e_digito = 0, tem_ponto = 0;
    while (*str) {
        if (isdigit(*str)) {
            e_digito = 1;
        } else if (*str == '.') {
            if (tem_ponto) return 0;
            tem_ponto = 1;
        } else {
            return 0;
        }
        str++;
    }
    return e_digito;
}

int e_string(const char *str) {
    size_t len = strlen(str);
    return len >= 2 && str[0] == '"' && str[len - 1] == '"';
}

char* verificar_tipo(const char *str) {
    if (e_numero(str)) {
        return "NUMERO";
    } else if (e_string(str)) {
        return "CADEIA";
    }
    return NULL;
}



%}
%union 
{
    int number;
    char *string;
}
%token BLOCO_INICIO BLOCO_FIM IDENTIFICADOR CADEIA %token NUMERO %token TIPO_INTEIRO TIPO_STRING PRINT
%%
program:
    program statement 
    |
    ;
statement:
    bloco_inicio
    | bloco_fim
    | declaration ';'
    | assignment ';'
    | print_statement ';'
    |
    ;
bloco_inicio:
    BLOCO_INICIO { empilha(); }
    ;
bloco_fim:
    BLOCO_FIM { desempilha(); }
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
        char* var_name = apaga_esp($1.string);
        if (variavel_pilha(var_name) == NULL || variavel_bloco(var_name) == NULL) {
            var_cadeia("CADEIA", var_name, $3.string, "declaration");
        } else if (strcmp(buscar_tipo_linha_variavel(var_name), "assignment") == 0) {
            atualiza_variavel("CADEIA", var_name, 0, $3.string, "declaration");
        } else {
            printf("Erro: variável '%s' já declarada no Pilha\n", var_name);
        }
    }
    | IDENTIFICADOR {
        char* var_name = apaga_esp($1.string);
        if (variavel_pilha(var_name) == NULL || variavel_bloco(var_name) == NULL) {
            var_cadeia("CADEIA", var_name, "", "declaration");
        } else if (strcmp(buscar_tipo_linha_variavel(var_name), "assignment") == 0) {
            atualiza_variavel("CADEIA", var_name, 0, "", "declaration");
        } else {
            printf("Erro: variável '%s' já declarada no Pilha\n", var_name);
        }
    }
    ;
expr_str:
    CADEIA { $$.string = apaga_espa_aspas($1.string); }
    | IDENTIFICADOR {
        char* var_name = apaga_esp($1.string);
        if(variavel_pilha(var_name) != NULL && strcmp(verifica_tipo_variavel(var_name), "CADEIA") == 0) {
            $$.string = variavel_str(var_name);
        } else {
            printf("Erro: tipos não compatíveis\n");
        }
    }
    | expr_str '+' CADEIA {
        char* part1 = retira_ultimo_digito($1.string);
        char* part2 = apaga_espa_aspas($3.string);
        part2 = retira_primeiro_digito(part2);
        size_t len1 = strlen(part1);
        size_t len2 = strlen(part2);
        char* result = (char*)malloc(len1 + len2 + 1);
        strcpy(result, part1);
        strcat(result, part2);
        $$.string = result;
    }
    | expr_str '+' IDENTIFICADOR {
        char* var_name = apaga_esp($3.string);
        if(variavel_pilha(var_name) != NULL && strcmp(verifica_tipo_variavel(var_name), "CADEIA") == 0) {
            char* part1 = retira_ultimo_digito($1.string);
            char* part2 = variavel_str(var_name);
            part2 = retira_primeiro_digito(part2);
            size_t len1 = strlen(part1);
            size_t len2 = strlen(part2);
            char* result = (char*)malloc(len1 + len2 + 1);
            strcpy(result, part1);
            strcat(result, part2);
            $$.string = result;
        } else {
            printf("Erro: tipos não compatíveis\n");
        }
    }
    ;
declaration_list_num:
    declaracao_numero
    | declaration_list_num ',' declaracao_numero
    ;
declaracao_numero:
    IDENTIFICADOR '=' expressao_numero { 
        char* var_name = apaga_esp($1.string);
        if (variavel_pilha(var_name) == NULL || variavel_bloco(var_name) == NULL) {
            var_numero("NUMERO", var_name, $3.number, "declaration");
        } else if (strcmp(buscar_tipo_linha_variavel(var_name), "assignment") == 0) {
            atualiza_variavel("NUMERO", var_name, $3.number, "", "declaration");
        } else {
            printf("Erro: variável '%s' já declarada no Pilha\n", var_name);
        }
    }
    | IDENTIFICADOR {
        char* var_name = apaga_esp($1.string);
        if (variavel_pilha(var_name) == NULL || variavel_bloco(var_name) == NULL) {
            var_numero("NUMERO", var_name, 0, "declaration");
        } else if (strcmp(buscar_tipo_linha_variavel(var_name), "assignment") == 0) {
            atualiza_variavel("NUMERO", var_name, 0, "", "declaration");
        } else {
            printf("Erro: variável '%s' já declarada no Pilha\n", var_name);
        }
    }
    ;
expressao_numero:
    NUMERO { $$.number = $1.number; }
    | IDENTIFICADOR {
        char* var_name = apaga_esp($1.string);
        if(variavel_pilha(var_name) != NULL && strcmp(verifica_tipo_variavel(var_name), "NUMERO") == 0) {
            $$.number = menor_var(var_name);
        } else {
            printf("Erro: tipos não compatíveis\n");
        }
    }
    | expressao_numero '+' NUMERO { $$.number = $1.number + $3.number; }
    | expressao_numero '+' IDENTIFICADOR {
        char* var_name = apaga_esp($3.string);
        if(variavel_pilha(var_name) != NULL && strcmp(verifica_tipo_variavel(var_name), "NUMERO") == 0) {
            $$.number = $1.number + menor_var(var_name);
        } else {
            printf("Erro: tipos não compatíveis\n");
        }
    }
    ;
assignment:
    IDENTIFICADOR '=' expr {
        char* expr_type = verificar_tipo($3.string);
        char* var_name = apaga_esp($1.string);
        if (variavel_pilha(var_name) != NULL) {
            char* var_type = verifica_tipo_variavel(var_name);
            if (strcmp(var_type, expr_type) == 0) {
                if (variavel_bloco(var_name) == NULL) {
                    if (strcmp(expr_type, "NUMERO") == 0) {
                        var_numero("NUMERO", var_name, atoi($3.string), "assignment");
                    } else if (strcmp(expr_type, "CADEIA") == 0) {
                        var_cadeia("CADEIA", var_name, $3.string, "assignment");
                    }
                } else {
                    if (strcmp(expr_type, "NUMERO") == 0) {
                        atualiza_variavel("NUMERO", var_name, atoi($3.string), "", "assignment");
                    } else if (strcmp(expr_type, "CADEIA") == 0) {
                        char* new_str = (char *)malloc((strlen($3.string) + 1) * sizeof(char));
                        strcpy(new_str, $3.string);
                        atualiza_variavel("CADEIA", var_name, 0, new_str, "assignment");
                        free(new_str);
                    } else {
                        printf("Erro: tipo inválido\n");
                    }
                }
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            printf("Erro: variável '%s' não declarada\n", var_name);
        }
    }
    ;
expr:
    NUMERO { $$.string = num_em_str($1.number); }
    | CADEIA { $$.string = apaga_espa_aspas($1.string); }
    | IDENTIFICADOR {
        char* var_name = apaga_esp($1.string);
        if (variavel_pilha(var_name) != NULL) {
            if (strcmp(verifica_tipo_variavel(var_name), "NUMERO") == 0) {
                $$.string = num_em_str(menor_var(var_name));
            } else if (strcmp(verifica_tipo_variavel(var_name), "CADEIA") == 0) {
                $$.string = variavel_str(var_name);
            } else {
                printf("Erro: variável '%s' com tipo inválido\n", var_name);
            }
        } else {
            printf("Erro: variável '%s' não declarada\n", var_name);
        }
    }
    | expr '+' NUMERO {
        if (strcmp(verificar_tipo($1.string), "NUMERO") == 0) {
            $$.string = num_em_str(atoi($1.string) + $3.number);
        } else {
            printf("Erro: Tipos incompatíveis\n");
        }
    }
    | expr '+' CADEIA {
        if (strcmp(verificar_tipo($1.string), "CADEIA") == 0) {
            char* part1 = retira_ultimo_digito($1.string);
            char* part2 = apaga_espa_aspas($3.string);
            part2 = retira_primeiro_digito(part2);
            size_t len1 = strlen(part1);
            size_t len2 = strlen(part2);
            char* result = (char*)malloc(len1 + len2 + 1);
            strcpy(result, part1);
            strcat(result, part2);
            $$.string = result;
        } else {
            printf("Erro: Tipos incompatíveis\n");
        }
    }
    | expr '+' IDENTIFICADOR {
        char* expr_type = verificar_tipo($1.string);
        char* var_name = apaga_esp($3.string);
        if (variavel_pilha(var_name) != NULL) {
            if (strcmp(expr_type, verifica_tipo_variavel(var_name)) == 0) {
                if (strcmp(expr_type, "NUMERO") == 0) {
                    $$.string = num_em_str(atoi($1.string) + menor_var(var_name));
                } else if (strcmp(expr_type, "CADEIA") == 0) {
                    char* part1 = retira_ultimo_digito($1.string);
                    char* part2 = variavel_str(var_name);
                    part2 = retira_primeiro_digito(part2);
                    size_t len1 = strlen(part1);
                    size_t len2 = strlen(part2);
                    char* result = (char*)malloc(len1 + len2 + 1);
                    strcpy(result, part1);
                    strcat(result, part2);
                    $$.string = result;
                }
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            printf("Erro: variável '%s' não declarada\n", var_name);
        }
    }
    ;
print_statement:
    PRINT IDENTIFICADOR {
        char* var_name = apaga_esp($2.string);
        if (variavel_pilha(var_name) != NULL) {
            if (strcmp(verifica_tipo_variavel(var_name), "NUMERO") == 0) {
                printf(" %d\n", menor_var(var_name));
            } else {
                printf(" %s\n", variavel_str(var_name));
            }
        } else {
            printf("Erro: variável não declarada\n");
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
