using Statistics

"""
	optimize_embedding_parameters(x::Vector{T}, max_dim::Int=3, max_lag::Int=50, method::String="acf")
	Determine the optimal delay and embedding dimension for the given time series.
	The optimal delay is determined by the first minimum of the auto-correlation function.
	The optimal embedding dimension is determined by the first minimum of the average mutual information.
	The function returns the optimal delay and embedding dimension.
	
	# Arguments
	- x::Vector{T}: Time series data.
	- max_dim::Int: Maximum embedding dimension to search for.
	- max_lag::Int: Maximum lag to search for the optimal delay.
	- method::String: Method to use for determining the optimal delay. "acf" for auto-correlation function, "ami" for average mutual information.
"""
function optimize_embedding_parameters(x::Vector{T}, max_dim::Int=3, max_lag::Int=50, method::String="acf",) where {T<:Real}
    delay = optimal_delay(x, max_lag, method)
    embedding_dim = false_nearest_neighbors(x, max_dim, delay)
    return delay, embedding_dim
end

"""
	optimal_delay(x::Vector{T}, max_lag::Int=100, method::String="acf")
	Determine the optimal delay for the given time series.
	The optimal delay is determined by the first minimum of the auto-correlation function.
	The function returns the optimal delay.
	
	# Arguments
	- x::Vector{T}: Time series data.
	- max_lag::Int: Maximum lag to search for the optimal delay.
	- method::String: Method to use for determining the optimal delay. "acf" for auto-correlation function, "ami" for average mutual information.
"""
function optimal_delay(x::Vector{T}, max_lag::Int=100, method="acf") where {T<:Real}
    # check if the method is valid
    if method == "acf"
        return optimal_delay_acf(x)
    elseif method == "ami"
        return optimal_delay_ami(x, max_lag)
    else
        throw(ArgumentError("Invalid method. Use 'acf' or 'ami'."))
    end
end

"""
	optimal_delay_acf(x::Vector{T})
	Determine the optimal delay for the given time series using the auto-correlation function.
	The optimal delay is determined by the first minimum of the auto-correlation function.
	The function returns the optimal delay.
	
	# Arguments
	- x::Vector{T}: Time series data.
"""
function optimal_delay_acf(x::Vector{T}) where {T<:Real}
    n = length(x)
    acf = [cor(x[1:end-k], x[1+k:end]) for k in 1:round(Int, n / 2)]
    delay = findfirst(t -> t < 1 / MathConstants.e, acf)
    return delay === nothing ? 1 : delay
end

"""
	optimal_delay_ami(x::Vector{T}, max_lag::Int=50)
	Determine the optimal delay for the given time series using the average mutual information.
	The optimal delay is determined by the first minimum of the average mutual information.
	The function returns the optimal delay.
	
	# Arguments
	- x::Vector{T}: Time series data.
	- max_lag::Int: Maximum lag to search for the optimal delay.
"""
function optimal_delay_ami(x::Vector{T}, max_lag::Int=50) where {T<:Real}
    ami = zeros(Float64, max_lag)
    n = length(x)
    for τ in 1:max_lag
        p_x = x[1:end-τ]
        p_y = x[τ+1:end]
        joint_hist = histogram2d(p_x, p_y, 20)
        p_joint = joint_hist.weights ./ sum(joint_hist.weights)
        p_x = sum(joint_hist.weights, dims=2) ./ sum(joint_hist.weights)
        p_y = sum(joint_hist.weights, dims=1) ./ sum(joint_hist.weights)
        ami[τ] = sum(p_joint .* log.(p_joint ./ (p_x * p_y) + eps()))
    end
    delay = findfirst(t -> t == minimum(ami), ami)
    return delay
end

function histogram2d(x::Vector{T}, y::Vector{T}, nbins::Int) where {T<:Real}
    x_edges = range(minimum(x), stop=maximum(x), length=nbins+1)
    y_edges = range(minimum(y), stop=maximum(y), length=nbins+1)
    hist = zeros(Int, nbins, nbins)
    for i in 1:length(x)
        x_bin = searchsortedfirst(x_edges, x[i]) - 1
        y_bin = searchsortedfirst(y_edges, y[i]) - 1
        if x_bin > 0 && x_bin <= nbins && y_bin > 0 && y_bin <= nbins
            hist[x_bin, y_bin] += 1
        end
    end
    return Histogram2D(hist, x_edges, y_edges)
end

struct Histogram2D
    weights::Array{Int,2}
    x_edges::Vector{Float64}
    y_edges::Vector{Float64}
end

"""
	false_nearest_neighbors(x::Vector{T}, max_dim::Int, delay::Int, r_thresh::Float64=10.0)
	Determine the optimal embedding dimension for the given time series.
	The optimal embedding dimension is determined by the first minimum of the false nearest neighbors ratio.
	The function returns the optimal embedding dimension.
	
	# Arguments
	- x::Vector{T}: Time series data.
	- max_dim::Int: Maximum embedding dimension to search for.
	- delay::Int: Delay for the time series.
	- r_thresh::Float64: Threshold for the false nearest neighbors ratio.
"""
function false_nearest_neighbors(x::Vector{T}, max_dim::Int, delay::Int, r_thresh::Float64=10.0) where {T<:Real}
    n = length(x)
    fnn_ratios = []
    # iterate over the embedding dimensions
    for d in 1:max_dim
        m = n - d * delay
        false_nearest = 0
        points = [x[i:delay:i+(d-1)*delay] for i in 1:m]
        # iterate over the points
        for i in 1:m
            min_distance = Inf
            min_idx = 0
            for j in 1:m
                if i != j
                    distance = norm(points[i]-points[j])
                    if distance < min_distance
                        min_distance = distance
                        min_idx = j
                    end
                end
            end
            neighbor_idx = min_idx
            distance_increase = abs(x[i+d*delay] - x[neighbor_idx+d*delay])
            if distance_increase / min_distance > r_thresh
                false_nearest += 1
            end
        end

        fnn_ratio = false_nearest / m
        push!(fnn_ratios, fnn_ratio)

        # check if the ratio is less than the threshold. if so, return the embedding dimension
        if fnn_ratio < 0.01
            return d
        end
    end
    # if the ratio is not less than the threshold, return the maximum embedding dimension
    return max_dim
end

"""
    nearest_neighbors(points::Vector{Vector{T}}, k::Int) where {T<:Real}
    Find the k-nearest neighbors for each point in the given set of points.
    The function returns a vector of vectors, where each inner vector contains the indices of the k-nearest neighbors for the corresponding point.
    
    # Arguments
    - points::Vector{Vector{T}}: Set of points.
    - k::Int: Number of nearest neighbors to find.
"""
function nearest_neighbors(points::Vector{Vector{T}}, k::Int) where {T<:Real}
    n = length(points)
    neighbors = Vector{Vector{Int}}(undef, n)
    for i in 1:n
        distances = [norm(points[i] - points[j]) for j in 1:n if i != j]
        sorted_indices = sortperm(distances)
        neighbors[i] = sorted_indices[1:k]
    end
    return neighbors
end