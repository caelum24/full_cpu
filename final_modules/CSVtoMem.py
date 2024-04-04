import csv
path = "/Users/willneuner/Desktop/processor/final_modules/"
# /Users/willneuner/Desktop/processor/final_modules
# "C:/Users/wjn7/Desktop/processor/final_modules" -> desktop path

with open(path + "colors.csv", "r") as csvFile:
       with open(path + "colors.mem", "w") as memFile:
            for row in csv.reader(csvFile):
                memFile.write(" ".join(row) + "\n")

with open(path + "training_grounds.csv", "r") as csvFile:
    with open(path + "image.mem", "w") as memFile:
        for row in csv.reader(csvFile):
            memFile.write(" ".join(row) + "\n")
