
clear; clc; close all;

% Data table has the following columns:
% "Any";"Codi municipi";"Municipi";"Comarca";"Població";"Autocompostatge";"Matèria orgànica";"Poda i jardineria";"Paper i cartró";"Vidre";"Envasos lleugers";"Residus voluminosos + fusta";"RAEE";"Ferralla";"Olis vegetals";"Tèxtil";"Runes";"Residus en Petites Quantitats (RPQ)";"Piles";"Medicaments";"Altres recollides selectives";"Total Recollida Selectiva";"R.S. / R.M. % total";"Kg/hab/any recollida selectiva";"Resta a Dipòsit";"Resta a Incineració";"Resta a Tractament Mecànic Biològic";"Resta (sense desglossar)";"Suma Fracció Resta";"F.R. / R.M. %";"Generació Residus Municipal Totals";"Kg / hab / dia";"Kg / hab / any"

%% Import the dataset and preprocess it
Dataset = readtable('./dades.xlsx');

% Delete unnecessary columns
columnsToKeep = {'Any', 'TotalRecollidaSelectiva', 'Generaci_ResidusMunicipalTotals', 'SumaFracci_Resta'};
Residues = Dataset(:, columnsToKeep);

% Rename column for easier access
Residues.Properties.VariableNames{'Generaci_ResidusMunicipalTotals'} = 'Totals';
Residues.Properties.VariableNames{'SumaFracci_Resta'} = 'Resta';
Residues.Properties.VariableNames{'TotalRecollidaSelectiva'} = 'Selectiva';

% Convert year to datetime
Residues.Any = datetime(Residues.Any, 'InputFormat', 'yyyy');
% Group Recollida Selectiva by year
TotalSelectiva = varfun(@sum, Residues, 'InputVariables', 'Selectiva', 'GroupingVariables', 'Any');
% Group Resta by year
TotalResta = varfun(@sum, Residues, 'InputVariables', 'Resta', 'GroupingVariables', 'Any');
% Group Generació Residus Municipal Totals by year
TotalResidues = varfun(@sum, Residues, 'InputVariables', 'Totals', 'GroupingVariables', 'Any');

% Calculate the fraction of Selectiva over TotalResidues
TotalSelectiva.Fraction = TotalSelectiva.sum_Selectiva ./ TotalResidues.sum_Totals;

%% Perform linear regression on Selective collection fraction from 2019 to 2023

% Extract the data from the years 2019 to 2023
yearsSubset = TotalSelectiva(TotalSelectiva.Any >= datetime(2019,1,1) & TotalSelectiva.Any <= datetime(2023,1,1), :);

% Perform linear regression
fitSelective = polyfit(yearsSubset.Any.Year, yearsSubset.Fraction, 1);
fprintf('Linear fit equation: y = %.2fx + %.2f\n', fitSelective(1), fitSelective(2));

% Predict the selective collection for the year 2024
yearToPredict = 2024;
predictedValue = polyval(fitSelective, yearToPredict);
fprintf('Predicted selective collection for %d: %.2f\n', yearToPredict, predictedValue * 100);


%% Plots


% All the data
figure;
hold on;
plot(TotalSelectiva.Any, TotalSelectiva.sum_Selectiva, '-o', 'LineWidth', 2, 'MarkerSize', 6);
plot(TotalResta.Any, TotalResta.sum_Resta, '-o', 'LineWidth', 2, 'MarkerSize', 6);
plot(TotalResidues.Any, TotalResidues.sum_Totals, '-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Year', 'FontSize', 12);
ylabel('Amount', 'FontSize', 12);
title('Selective Collection and Resta over the Years', 'FontSize', 14);
legend('Total Selective', 'Total Resta', 'Total Residues', 'Location', 'northwest');
grid on;
hold off;
% Save the figure
saveas(gcf, 'report/Figures/residues_history.png');


% Fraction of the Selectiva over Total Residues
figure;
plot(TotalSelectiva.Any, TotalSelectiva.Fraction * 100, '-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Year', 'FontSize', 12);
ylabel('Selective Collection (%)', 'FontSize', 12);
title('Fraction of Selective Collection over Total Residues', 'FontSize', 14);
grid on;
% Save the figure
saveas(gcf, 'report/Figures/selective_collection_fraction.png');


% Plot the subset data and the linear fit
figure;
plot(yearsSubset.Any, yearsSubset.Fraction * 100, 'o', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
plot(yearsSubset.Any, polyval(fitSelective, yearsSubset.Any.Year) * 100, '-r', 'LineWidth', 2);
xlabel('Year', 'FontSize', 12);
ylabel('Selective Collection (%)', 'FontSize', 12);
title('Linear Fit of Selective Collection (2019-2023)', 'FontSize', 14);
grid on;
xticks(yearsSubset.Any);
xtickformat('yyyy');
set(gca, 'FontSize', 10);
legend('Data', 'Linear Fit', 'Location', 'northwest');
hold off;
% Save the figure
saveas(gcf, 'report/Figures/linear_fit_2019_2023.png');


