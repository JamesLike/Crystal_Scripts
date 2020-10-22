clear all
cd /home/jb2717/Data2/serial_march_2019/processing
addpath /home/jb2717/Progs/grep_matlab
folders=dir('c*');
close all


for j=1:length(folders)
 cd(folders(j).name)
 folders(j).name

 clear RAW_CELLS
 clear A
 [A,RAW_CELLS]=unix('grep UNIT\ CELL\ PARAM IDXREF.LP');

    for i=1:(length(RAW_CELLS)/77)

        a(i,j)=str2num(RAW_CELLS((27+((i-1)*77):33+((i-1)*77))));
        b(i,j)=str2num(RAW_CELLS((37+((i-1)*77):43+((i-1)*77))));
        c(i,j)=str2num(RAW_CELLS((47+((i-1)*77):53+((i-1)*77))));

    end
chip{j}=sprintf('%s', folders(j).name)


cd ../
end

h=mean(nonzeros(a));
k=mean(nonzeros(b));
l=mean(nonzeros(c));


fig_1=figure ('Position', [10 10 1200 600]);
clf
for j=1:6
fig_1;
subplot(1,3,1);
histogram(a(:,j),1000,'BINLIMITS',[38,42],'DisplayName',chip{j}(1:6),'LineStyle', 'none')
xlim([39.4 40.2])
title('a')
hold on
subplot(1,3,2);
histogram(b(:,j),1000,'BINLIMITS',[73,77],'DisplayName',chip{j}(1:6),'LineStyle', 'none')
xlim([74.4 75.2])
xlabel('Length (A)')
%title(chip,'Interpreter', 'none')
title('b')
hold on
subplot(1,3,3);
histogram(c(:,j),1000,'BINLIMITS',[77, 81],'DisplayName',chip{j}(1:6),'LineStyle', 'none')
xlim([78.9 79.7])
title('c')
hold on
%subplot(1,4,4)
legend('Location', 'northeast')
end
fig_1
subplot(1,3,1)
line([mean(nonzeros(a)), mean(nonzeros(a))], ylim, 'LineWidth', 2, 'Color', 'r');
subplot(1,3,2)
line([mean(nonzeros(b)), mean(nonzeros(b))], ylim, 'LineWidth', 2, 'Color', 'r');
subplot(1,3,3)
line([mean(nonzeros(c)), mean(nonzeros(c))], ylim, 'LineWidth', 2, 'Color', 'r','DisplayName','Mean');


fig_2=figure ('Position', [10 10 1200 600]);
clf
for j=11:-1:7Hell0
fig_2;
subplot(1,3,1)
histogram(a(:,j),1000,'BINLIMITS',[38,42],'DisplayName',chip{j}(1:6),'LineStyle', 'none')
xlim([39.4 40.2])
title('a')
hold on
subplot(1,3,2)
histogram(b(:,j),1000,'BINLIMITS',[73,77],'DisplayName',chip{j}(1:6),'LineStyle', 'none')
xlim([74.4 75.2])
title('b')
xlabel('Length (A)')
%title(chip,'Interpreter', 'none')
hold on
subplot(1,3,3)
histogram(c(:,j),1000,'BINLIMITS',[77, 81],'DisplayName',chip{j}(1:6),'LineStyle', 'none')
xlim([78.9 79.7])
title('c')
hold on
%subplot(1,4,4)
legend('Location', 'northeast')
end



fig_2
subplot(1,3,1)
line([mean(nonzeros(a)), mean(nonzeros(a))], ylim, 'LineWidth', 2, 'Color', 'r');
subplot(1,3,2)
line([mean(nonzeros(b)), mean(nonzeros(b))], ylim, 'LineWidth', 2, 'Color', 'r');
subplot(1,3,3)
line([mean(nonzeros(c)), mean(nonzeros(c))], ylim, 'LineWidth', 2, 'Color', 'r','DisplayName','Mean');