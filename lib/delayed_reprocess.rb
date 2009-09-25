class	DelayedReprocess

	attr_accessor :full
  def initialize(full)
    self.full = full
  end

	def perform
	  if full
	    ExecutionSummary.build_full_summary     
	  else
	    ExecutionSummary.build_summary
    end    
	end

end