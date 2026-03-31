FROM docker.io/library/erlang:26

# Install bash
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy project
COPY atom_project /workspace/atom_project

# Set permissions for the script
RUN chmod +x /workspace/atom_project/scripts/ping_server.sh

# Build
WORKDIR /workspace/atom_project
RUN rebar3 compile

# Command to run tests
CMD ["rebar3", "ct"]
