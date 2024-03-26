def arraydiv_maker(n):
    # making row 0
    wire_maker(n, 0, "c")
    wire_maker(n, 0, "s")
    cell_maker(n, 0)
    print(f"assign Q[{n-1}] = c_0_0;")

    #making all of the other rows
    for i in range(1, n):
        wire_maker(n, i, "c")
        wire_maker(n, i, "s")
        cell_maker(n, i)
        print(f"assign Q[{n-1-i}] = c_{i}_{i};")


def wire_maker(n, row, type): #good
    # making the wire declaration
    wire_string = "wire "
    if type == "c":
        wire_string += f"{type}_{row}_{row}, "
    elif type == "s":
        wire_string += f"empty{row}, "
    for i in range(1, n-1):
        wire_string += f"{type}_{row}_{row+i}, "
    wire_string += f"{type}_{row}_{row+n-1}"
    wire_string += ";"
    print(wire_string)

def cell_maker(n, row):
    if row == 0:
        print(f"divider_cell cell_{row}_{row}(empty{row}, c_{row}_{row}, divisor[{n-1}], dividend[{2*n-2}], c_{row}_{row+1}, 1'b1);")
        for i in range(1, n-1):
            print(f"divider_cell cell_{row}_{row+i}(s_{row}_{row+i}, c_{row}_{row+i}, divisor[{n-1-i}], dividend[{2*n-2-i}], c_{row}_{row+i+1}, 1'b1);")
        print(f"divider_cell cell_{row}_{row+n-1}(s_{row}_{row+n-1}, c_{row}_{row+n-1}, divisor[0], dividend[{n-1}], 1'b1, 1'b1);")
    else:
        print(f"divider_cell cell_{row}_{row}(empty{row}, c_{row}_{row}, divisor[{n-1}], s_{row-1}_{row}, c_{row}_{row+1}, c_{row-1}_{row-1});")
        for i in range(1, n-1):
            print(f"divider_cell cell_{row}_{row+i}(s_{row}_{row+i}, c_{row}_{row+i}, divisor[{n-1-i}], s_{row-1}_{row+i}, c_{row}_{row+1+i}, c_{row-1}_{row-1});")
        print(f"divider_cell cell_{row}_{row+n-1}(s_{row}_{row+n-1}, c_{row}_{row+n-1}, divisor[0], dividend[{n-1-row}], c_{row-1}_{row-1}, c_{row-1}_{row-1});")
        
if __name__ == "__main__":
    arraydiv_maker(32)
