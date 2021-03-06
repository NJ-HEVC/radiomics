function calcAllFeatureSetsTime_HN(pathSet,training,pathMINE,param,setSize,alpha,delta,nBoot,seed,batchNum)
% -------------------------------------------------------------------------
% function calcAllFeatureSets_HN(pathExperiment,trainingStruct,pathMINE,setSize,alpha,delta,nBoot,batchNum)
% -------------------------------------------------------------------------
% DESCRIPTION: 
% This function computes feature set reduction for a given feature set type 
% and for all experiments with different degrees of freedom. See ref. [1,2] 
% for more details.
% -------------------------------------------------------------------------
% REFERENCES:
% [1] Vallieres, M. et al. (2015). FDG-PET/CT radiomics models for the 
%     early prediction of different tumour outcomes in head and neck cancer.
%     The Journal of Nuclear Medicine, aa(bb), xxx-yyy. 
%     doi:
% [2] Vallieres, M. et al. (2015). A radiomics model from joint FDG-PET and 
%     MRI texture features for the prediction of lung metastases in soft-tissue 
%     sarcomas of the extremities. Physics in Medicine and Biology, 60(14), 
%     5471-5496. doi:10.1088/0031-9155/60/14/5471
% -------------------------------------------------------------------------
% INPUTS:
% 1. pathSet: Full path to the Feature Set folder of the corresponding experiment.
%             --> Ex: '/myProject/WORKSPACE/COHORT-BASED-RESULTS/Experiment1/FSET'
% 2. training: Structure defining all parameters for the given experiment 
%              to perform. See masterScript_HN.m for more details.
% 3. pathMINE: Full path to the MINE.jar executable. The executable can be
%              downloaded at: <http://www.exploredata.net/>.
%              --> Ex: '/myProject/radiomics/MultivariableModeling/MINE'
% 4. param: Cell of two strings, defining 1) The feature set type/name; and
%           2) the outcome to model
% 4. setSize: Size of the output feature set (typically set to 25 in ref. [1]).
%             --> Ex: 25
% 5. alpha: Numerical values specifying the coefficient of the first part of
%           the Gain equation, as defined in ref. [1,2].
%           --> Ex: 0.5 
% 6. delta: Numerical values specifying the coefficient of the second part 
%           of the Gain equation, as defined in ref. [1,2] (third part is set
%           to 0 in this function).
%           --> Ex: 0.5
% 7. nBoot: Number of bootstrap samples to use.
%           --> Ex: 100
% 8. seed: Numerical number to use as seed for bootstrapping experiment
%          --> Ex: 54288
%
% See <https://github.com/mvallieres/radiomics/tree/master/STUDIES/HNstudy/Functions>
% to find computeAllNonTextureFeatures_HN.m, organizeSeparateTextures_HN.m
% and organizeFusedTextures_HN.m. See masterScript_HN.m for a complete 
% example of how to utilize the current function.
% -------------------------------------------------------------------------
% OUTPUTS: Feature sets are saved in a folder named 'FSET' in the
% corresponding folder of "pathExperiment"
% -------------------------------------------------------------------------
% AUTHOR(S): Martin Vallieres <mart.vallieres@gmail.com>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: March 2016
%--------------------------------------------------------------------------
% STATEMENT:
% This file is part of <https://github.com/mvallieres/radiomics/>, 
% a package providing MATLAB programming tools for radiomics analysis.
% --> Copyright (C) 2015  Martin Vallieres
%
%    This package is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this package.  If not, see <http://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

startpath = pwd;
warning off
if nargin < 10
    batchNum = 1;
end

fSetName = param{1};
outcomeName = param{2};
outcome = training.(outcomeName).timeToEvent;
nonText = training.(outcomeName).nonText;
textCellsName = fieldnames(training.(outcomeName).text.(fSetName)); textCellsName(1:4) = []; % Removing 'param', 'baseline', 'freedom', 'paramName'
nTextCell = numel(textCellsName);
textCells = cell(1,nTextCell);
for i = 1:nTextCell
    textCells{i} = training.(outcomeName).text.(fSetName).(textCellsName {i});
end
paramAll = training.(outcomeName).text.(fSetName).param;
freedomMat = training.(outcomeName).text.(fSetName).freedom;
baseline = training.(outcomeName).text.(fSetName).baseline;

tic
fprintf(['\n--> COMPUTING "',fSetName,'" FEATURE SET FOR "',outcomeName,'" OUTCOME ... '])
[fSet] = featureSetReductionTime_HN(pathMINE,fSetName,outcome,setSize,nonText,textCells,textCellsName,paramAll,freedomMat,baseline,alpha,delta,nBoot,seed,batchNum);
cd(pathSet), save(['FSET_',fSetName,'_',outcomeName],'fSet')
fprintf('DONE!\n'), toc

cd(startpath)
end
