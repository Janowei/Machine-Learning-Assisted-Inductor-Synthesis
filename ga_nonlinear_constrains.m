% this function is a nonlinear constraint on the GA optimization
% contain area constraints and Expanded Wheeler Formula constraints
function [c,ceq] = ga_nonlinear_constrains(geomParam,Param)

% calculate the size of the inductor
Area = calculate_area(geomParam);
innerDiaWidth = Area.innerDiaWidth;
innerDiaHeight = Area.innerDiaHeight;
outerDiaHeight = Area.outerDiaHeight;
outerDiaWidth = Area.outerDiaWidth;

% calculating DC inductance values using the Extended Wheeler Formula
averageDia = sqrt((outerDiaHeight+innerDiaHeight).*(outerDiaWidth+innerDiaWidth))./2.*1e-6;
rho = (sqrt(outerDiaWidth.*outerDiaHeight)-sqrt(innerDiaHeight.*innerDiaWidth))./...
    (sqrt(outerDiaWidth.*outerDiaHeight)+sqrt(innerDiaHeight.*innerDiaWidth));
Ldc = ((2.34*4*pi*(1e-7).*geomParam(:,4).^2.*averageDia)./(1+3.99.*rho))*1e9;

% the area and EWF constraints need to be satisfied
c = [outerDiaWidth+0.5-Param.maxArea(1);...
    outerDiaHeight+0.5-Param.maxArea(2);...
    abs(Ldc-Param.targetL)/Param.targetL-0.3];
% no nonlinear equation constraint
ceq = [];
end