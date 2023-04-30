classdef group_overlapEdges
    properties
        subjects1; % N* 268*268
        subjects2;
%         phenotypes;
        group_size1;% N
        group_size2;
        num_node1;
        num_node2;
        num_task1;
        num_task2;
        num_edge1;
        num_edge2;
        all_edges1;
        all_edges2;
        gender1;
        gender2;
        issym1;
        issym2;
        k_fold; % number of folds
    end
    methods
        function this = group_overlapEdges(subjects1,subjects2)
            % subjects1:
            this.subjects1 = subjects1;
            this.group_size1 = size(subjects1,2);
            this.num_node1 = subjects1(1).num_node;
            this.num_edge1 = subjects1(1).num_edge;
            this.num_task1 = subjects1(1).num_task;
            this.issym1 = subjects1(1).issym;
            this.all_edges1 = zeros(this.num_edge1,this.group_size1,this.num_task1);
            this.gender1 = zeros(this.group_size1,1);
            for i=1:this.group_size1
                this.all_edges1(:,i,:) = this.subjects1(i).all_edges;
            end

            % subjects2:
            this.subjects2 = subjects2;
            this.group_size2 = size(subjects2,2);
            this.num_node2 = subjects2(1).num_node;
            this.num_edge2 = subjects2(1).num_edge;
            this.num_task2 = subjects2(1).num_task;
            this.issym2 = subjects2(1).issym;
            this.all_edges2 = zeros(this.num_edge2,this.group_size2,this.num_task2);
            this.gender2 = zeros(this.group_size2,1);
            for i=1:this.group_size2
                this.all_edges2(:,i,:) = this.subjects2(i).all_edges;
            end

        end
    end
end