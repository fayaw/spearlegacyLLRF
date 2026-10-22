function cavabsval = cavabsfun(w,Ql,Wc,k)

cavabsval = k*sqrt(w.^2*Wc^2./ ...
    (Ql^2*w.^4 + w.^2*Wc.^2 - 2*Ql^2*w.^2*Wc.^2+Ql^2*Wc.^4));
