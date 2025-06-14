import pandas as pd
import numpy as np
import itertools

# Representa uma rede neural muito simples: cada regra vira um neurônio oculto
class CILPNetwork:
    def __init__(self, rules):
        self.literals = set()
        self.rules = self.parse_rules(rules)
        self.build_network()

    def parse_rules(self, rules):
        parsed = []
        for _, row in rules.iterrows():
            head = row['head'].strip()
            body = row['body'].strip()
            if body:
                terms = [term.strip() for term in body.split('and')]
                positives = [t for t in terms if not t.startswith('not')]
                negatives = [t[4:] for t in terms if t.startswith('not')]
            else:
                positives = []
                negatives = []

            parsed.append({'head': head, 'pos': positives, 'neg': negatives})
            self.literals.update([head] + positives + negatives)
        return parsed

    def build_network(self):
        self.literal_list = sorted(self.literals)
        self.literal_index = {lit: i for i, lit in enumerate(self.literal_list)}
        self.input_size = len(self.literal_list)
        self.hidden_size = len(self.rules)
        self.output_size = self.input_size  # One output per literal

        # Pesos da camada de entrada para camada oculta
        self.w_input_hidden = np.zeros((self.hidden_size, self.input_size))
        self.bias_hidden = np.zeros(self.hidden_size)

        # Camada oculta para saída
        self.w_hidden_output = np.zeros((self.output_size, self.hidden_size))

        for i, rule in enumerate(self.rules):
            for lit in rule['pos']:
                self.w_input_hidden[i, self.literal_index[lit]] = 1
            for lit in rule['neg']:
                self.w_input_hidden[i, self.literal_index[lit]] = -1
            self.bias_hidden[i] = -len(rule['pos']) - 0.5 * len(rule['neg'])
            self.w_hidden_output[self.literal_index[rule['head']], i] = 1

    def sigmoid(self, x):
        return 1 / (1 + np.exp(-x))

    def forward(self, input_dict):
        x = np.array([1 if input_dict.get(lit, False) else 0 for lit in self.literal_list])
        hidden = self.sigmoid(np.dot(self.w_input_hidden, x) + self.bias_hidden)
        output = self.sigmoid(np.dot(self.w_hidden_output, hidden))
        return {lit: output[i] > 0.5 for i, lit in enumerate(self.literal_list)}


def gerar_tabela_verdade(variaveis):
    n = len(variaveis)
    combinacoes = list(itertools.product([1, -1], repeat=n))
    entradas = []
    for c in combinacoes:
        entrada = {variaveis[i]: (c[i] == 1) for i in range(n)}
        entradas.append(entrada)
    return entradas

def testar_todas_entradas(rede):
    variaveis = rede.literal_list
    entradas = gerar_tabela_verdade(variaveis)
    
    print(f"\nTabela verdade para {len(variaveis)} variáveis ({2**len(variaveis)} combinações):\n")
    print("Entrada".ljust(50), "=> Saída")
    print("-" * 90)

    for entrada in entradas:
        saida = rede.forward(entrada)
        entrada_fmt = ', '.join(f"{k}={1 if v else -1}" for k, v in entrada.items())
        saida_fmt = ', '.join(f"{k}={1 if v else -1}" for k, v in saida.items())
        print(entrada_fmt.ljust(50), "=>", saida_fmt)

# -------------------------------
# Uso prático

def main():
    rules = pd.read_csv("programa_lp.csv")
    network = CILPNetwork(rules)

    testar_todas_entradas(network)

if __name__ == "__main__":
    main()
