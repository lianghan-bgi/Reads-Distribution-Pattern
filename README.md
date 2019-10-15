# Reads-Distribution-Pattern

This tool can be used to extract genome-wide reads distribution pattern through whole genome sequencing to classify samples.

--- Preparation ---

As we developed our method based on the reads count of a series of windows on the reference, it’s required that we prepared these data before extracting operations. Here, we recommend a tool readCount (https://github.com/broadinstitute/ichorCNA/wiki/Usage) to finish this work.

For human cfDNA data, we set the window length as 10K, an empire value.

In this repository, we prepared the reads count data of 30 cfDNA samples (10 healthy controls with prefix of “healthy”, 10 liver cancer samples with prefix of “liver” and 10 lung cancer samples with prefix of “lung” in the readCount folder) with fix-window-length of 1K. We then use the script “data.pl” in folder “script” to arrange them in advance.
```
perl ./script/data.pl HEALTH-BGI.list 10 > HEALTH-BGI.list.txt
perl ./script/data.pl LIVER-BGI.list 10 > LIVER-BGI.list.txt
perl ./script/data.pl LUNG-BGI.list 10 > LUNG-BGI.list.txt
```
where the *.list files contain the paths of 3 kind of samples separately, the parameter 10 means to fuse 10 reads counts of 1K-length window to obtain that of 10K-length of window. After this step, we obtained 3 data files with reads counts of 10K-length window. Each line in the data file represents a sample and each data file corresponds to a single kind of samples.

As we preformed 10-fold across validation in the paper, we separated the data files into 10 sample-equal parts

[Note] To get the same results with the paper, we recommend you to skip the step and use the provided *.part* files instead, as this step involves random factors which would change the results.

could be skipped ---begin 
```
perl ./script/randM.pl HEALTH-BGI.list.txt 10
perl ./script/randM.pl LIVER-BGI.list.txt 10
perl ./script/randM.pl LUNG-BGI.list.txt 10
```
could be skipped ---end

The script randM.pl separates a file in to the given number parts with equal lines randomly (or almost equal lines if the lines can’t be separated on average). After this step, we will obtain series files with postfix of “part*”.

We produced the 10 pairs of training and testing data with the part files. We created 10 folders T0~T9 to put those files.
```
perl -lne ‘for($a=0;$a<10;$a++){mkdir T$a}’
```
In T0, we copied the HEALTH.list.txt.part0 as the testing data of the healthy control and combined the rest HEALTH.list.txt.part1~ HEALTH.list.txt.part8 files as the training data.

cat HEALTH-BGI.list.txt.part0 > T0/HEALTH-BGI.list.txt.test ; cat HEALTH-BGI.list.txt.part1 HEALTH-BGI.list.txt.part2 HEALTH-BGI.list.txt.part3 HEALTH-BGI.list.txt.part4 HEALTH-BGI.list.txt.part5 HEALTH-BGI.list.txt.part6 HEALTH-BGI.list.txt.part7 HEALTH-BGI.list.txt.part8 HEALTH-BGI.list.txt.part9 > T0/HEALTH-BGI.list.txt.train

We then repeat this step for other Tx folders and sample kinds. The following command could finish these steps faster.
```
ls *.list.txt | perl -lne 'BEGIN{$fold=10}$file=$_;for($a=0;$a<$fold;$a++){print "cat $file.part$a > T$a/$file.test";$s="";for($b=0;$b<$fold;$b++){$s.=" $file.part$b" if($a!=$b)}print "cat$s > T$a/$file.train"}' | bash
```
Now, please switch into the folder “tree” and compile the tools.

cd tree ; bash make.sh ; cd ..

--- Extract the frequent reads distribution patterns (RDPs)---

To extract the frequent RDPs of healthy control in T0, we use the tool “tree” in the folder “tree”

./tree/tree --input ./T0/HEALTH-BGI.list.txt.train --coverage 0.6 > ./T0/HEALTH-BGI.list.txt.train.half

The parameter 0.6 following the item --coverage claims we want the RDPs with coverage no less then 60%. A lower coverage would take more times, for the 0.6, it took several hours in our computer with Intel® Core™ i5-4590 CPU @ 3.30GHz × 4 . We provided the half.sh containing the commands for all training data. We recommend you to run the commands concurrently with the same number of CPU cores. For a quick validation of this method, please decompress the files *.list.txt.train.half.tar.gz which are pre-computed for T0, and move them into folder T0

tar -zxvf HEALTH-BGI.list.txt.train.half.tar.gz ; mv HEALTH-BGI.list.txt.train.half T0 ; tar -zxvf LIVER-BGI.list.txt.train.half.tar.gz ; mv LIVER-BGI.list.txt.train.half T0 ; tar -zxvf LUNG-BGI.list.txt.train.half.tar.gz ; mv LUNG-BGI.list.txt.train.half T0

Now, let's switch into the folder "T0" and continue.

cd T0

--- Find out type-special RDPs and verification ---

We used the tool “fisher” to measure how special an RDP is for one kind of samples comparing to another kind. For example, for liver cancer comparing to healthy control

../tree/fisher --input ./HEALTH-BGI.list.txt.train --half ./LIVER-BGI.list.txt.train.half > ./LIVER-BGI.HEALTH-BGI.complete

Here, we can run the file fisher.sh directly.

bash fisher.sh

Then we need to selected a proper size of the most effective RDPs to structure models.

../tree/balance --input0 ./LIVER-BGI.list.txt.train --input1 ./HEALTH-BGI.list.txt.train --complete0 ./LIVER-BGI.HEALTH-BGI.complete --complete1 ./HEALTH-BGI.LIVER-BGI.complete --balance0 ./LIVER-BGI.HEALTH-BGI.balance --balance1 ./HEALTH-BGI.LIVER-BGI.balance --max 50

Where, the parameter 50 following the item --max claims we just want no more than 50 RDPs. Too many RDPs would increase the possibility of overfitting. Here, we can run the file balance.sh directly.

bash balance.sh

The selected RDPs will be stored in the *.balance files. We next use them to predict the testing data. Let’s create 3 folders here.

mkdir HEALTH-BGI ; mkdir LIVER-BGI ; mkdir LUNG-BGI

../tree/balance --input0 ./HEALTH-BGI.list.txt.test --complete0 ./LIVER-BGI.HEALTH-BGI.balance --complete1 ./HEALTH-BGI.LIVER-BGI.balance > ./HEALTH-BGI/LIVER-BGI.HEALTH-BGI.txt

Here, we predict the samples in ./HEALTH-BGI.list.txt.test with RDPs in ./LIVER-BGI.HEALTH-BGI.balance and in ./HEALTH-BGI.LIVER-BGI.balance. This step will produce two scores corresponding to the possibility of which kind (healthy / liver cancer here) a sample would belong to. See the file ./HEALTH-BGI/LIVER-BGI.HEALTH-BGI.txt . We can run the file judge.sh directly.

bash judge.sh

To collect the scores, please run the file score.sh

bash score.sh > table.txt

Now, the result of testing data of T0 is stored in table.txt. Switch other Tx folders and repeat those steps.

[Note] Please make sure the script half.sh has been ran and finished at first.

cd ../T1 ; mkdir HEALTH-BGI ; mkdir LIVER-BGI ; mkdir LUNG-BGI ; bash ../T0/fisher.sh ; bash ../T0/balance.sh ; bash ../T0/judge.sh ; bash ../T0/score.sh > table.txt ; 

cd ../T2 ; …

Finally, check all table.txt in Tx folder.

ls T*/table.txt > table.list ; perl script/collect.pl table.list > table.txt ; cat table.txt
