def wallace_tree_maker(n):

    # making row 1
    wire_maker(n, 0, "w")
    and_assignor(n, 0)
    print("assign result[0] = w_0_0;")


    #making all of the middle rows sequentially
    for i in range(1, n-1):
        middle_section_maker(n, i)
        print(f"assign result[{i}] = s_{i}_{i};")

    #making the final row
    final_row_maker(n)


def wire_maker(n, row, type):
    # making the wire declaration
    wire_string = "wire "
    for i in range(n-1):
        wire_string += f"{type}_{row}_{row+i}, "
    wire_string += f"{type}_{row}_{row+n-1}"
    wire_string += ";"
    print(wire_string)


def and_assignor(n, row):
    for i in range(n-1):
        print(f"assign w_{row}_{row+i} = data_operandA[{i}] & data_operandB[{row}];")

    print(f"assign w_{row}_{row+n-1} = ~(data_operandA[{n-1}] & data_operandB[{row}]);")

def add_creator(n, row):
    if row == 1:
        in_wire = "w"
        
    else:
        in_wire = "s"
    
    print(f"full_adder adder_{row}_{row}(.S(s_{row}_{row}), .Cout(c_{row}_{row}), .A({in_wire}_{row-1}_{row}), .B(w_{row}_{row}), .Cin(1'b0));")

    for i in range(1, n):
        if i == n-1 and row == 1:
            print(f"full_adder adder_{row}_{row+i}(.S(s_{row}_{row+i}), .Cout(c_{row}_{row+i}), .A(1'b1), .B(w_{row}_{row+i}), .Cin(c_{row}_{row+i-1}));")
        elif i == n-1:
            print(f"full_adder adder_{row}_{row+i}(.S(s_{row}_{row+i}), .Cout(c_{row}_{row+i}), .A(c_{row-1}_{row+i-1}), .B(w_{row}_{row+i}), .Cin(c_{row}_{row+i-1}));")
        else:
            print(f"full_adder adder_{row}_{row+i}(.S(s_{row}_{row+i}), .Cout(c_{row}_{row+i}), .A({in_wire}_{row-1}_{row+i}), .B(w_{row}_{row+i}), .Cin(c_{row}_{row+i-1}));")

def middle_section_maker(n, row):
    wire_maker(n, row, "w")
    wire_maker(n, row, "s")
    wire_maker(n, row, "c")

    and_assignor(n, row)

    add_creator(n, row)

def final_and_assignor(n):
    row = n-1
    for i in range(n-1):
        print(f"assign w_{row}_{row+i} = ~(data_operandA[{i}] & data_operandB[{row}]);")

    print(f"assign w_{row}_{row+n-1} = data_operandA[{n-1}] & data_operandB[{row}];")


def final_row_maker(n):
    wire_maker(n, n-1, "w")
    wire_maker(n, n-1, "s")
    print(f"wire s_{n-1}_{2*n-1};")
    wire_maker(n, n-1, "c")
    print(f"wire c_{n-1}_{2*n-1};")
    
    final_and_assignor(n)
    add_creator(n, n-1)
    print(f"full_adder adder_{n-1}_{2*n-1}(.S(s_{n-1}_{2*n-1}), .Cout(c_{n-1}_{2*n-1}), .A(1'b1), .B(c_{n-1}_{2*n-2}), .Cin(1'b0));")

    for i in range(0, n+1):
        print(f"assign result[{n-1+i}] = s_{n-1}_{n+i-1};")

    

if __name__ == "__main__":
    wallace_tree_maker(32)
