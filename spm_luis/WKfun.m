function varargout = WKfun(action,x1,V,W,titl)
% WKfun(action,x1,V)

switch (action)
    case {'stdev','var'}
        X = [ones(size(x1,1),1) x1];
        c = [0 1];
        if nargin<3 | isempty(V), V=speye(length(x1)); end
        if nargin<4 | isempty(W), W=speye(length(x1)); end
        varargout{1} = c*pinv(W*X)*W*V*W'*pinv(W*X)'*c';
        if strcmp(action,'stdev')
            varargout{1} = sqrt(varargout{1});
        end

    case 'mkW'
        %  [u s] = spm_svd(V);
        [u s] = svd(V);
        n = size(V,1);
        if length(s)<n,
            str = sprintf('Variance matrix V singular, %dx%d but rank = %d',...
                n,n,rank(V));
            error(str)
        end
        s     = spdiags(1./sqrt(diag(s)),0,n,n);
        W     = u*s*u';
        W     = W.*(abs(W) > 1e-6);
        W  = sparse(W);
        varargout{1} = W;

    case 'HRFconv'
        xc = conv(x1,spm_hrf(2));
        xc = xc(1:length(x1));
        varargout{1} = xc;

    case 'Cov2Cor'
        % Standardized covariance matrix into a correlation matrix
        Vo = x1;
        V = diag(1./sqrt(diag(Vo)))*Vo*diag(1./sqrt(diag(Vo)));
        varargout{1} = V;

    case 'AR+WN'
        rho = x1;   % AR rho
        VarR = V;   % Variance ratio, WN:ARN; VarR=0 -> AR(1); VarR=Inf -> WN
        n   = W;    % Time series length

        if isinf(VarR)
            V = eye(n);
        else
            V=(spm_Q(rho,n)+eye(n)*VarR)/(1+VarR);
        end
        varargout{1} = V;

    case 'plot'
        if nargin<4 | isempty(W), W=speye(length(x1)); end
        if nargin<5, titl = ''; end

        x1 = W*x1;
        set(gcf,'color','white')
        plot(x1,'b-o','linewidth',3)
        yl=min(x1);yu=max(x1);yr = yu-yl; yl=yl-0.04*yr;yu=yu+0.04*yr;
        set(gca,'xlim',[0 length(x1)+1],'ylim',[-0.15 1.15])
        set(gca,'fontsize',14)

        if ~isempty(titl),
            print('-dtiff','-r100',[titl '.tif'])
        end

    otherwise
        error('Unknown action')
end
